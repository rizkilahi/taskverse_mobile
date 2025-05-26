import 'package:flutter/material.dart';
import '../../../data/models/thread_model.dart';
import '../../../data/models/thread_member_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import 'dart:io';

class ThreadProvider with ChangeNotifier {
  // Menyimpan thread yang sedang aktif dan sidebar visibility
  String _selectedThreadId = 'hq-1-1'; // Default ke #lobby
  bool _showMembersSidebar = false;
  List<ThreadModel> _threads = ThreadModel.dummyThreads; // Menyimpan semua thread
  Map<String, List<MessageModel>> _threadMessages = {}; // Messages per thread
  
  // FIXED: Add counter untuk unique ID generation
  int _subThreadCounter = 0;
  
  // Search functionality
  String _searchQuery = '';
  List<MessageModel> _filteredMessages = [];
  
  // Getter untuk thread dan members
  String get selectedThreadId => _selectedThreadId;
  bool get showMembersSidebar => _showMembersSidebar;
  List<ThreadModel> get threads => _threads;
  Map<String, List<MessageModel>> get threadMessages => _threadMessages;
  String get searchQuery => _searchQuery;
  
  // Get messages for selected thread (dengan search filter)
  List<MessageModel> get selectedThreadMessages {
    final messages = _threadMessages[_selectedThreadId] ?? [];
    if (_searchQuery.isEmpty) {
      return messages;
    }
    return messages.where((message) => 
      message.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      message.sender.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  // Get HQ threads (tipe HQ)
  List<ThreadModel> get hqThreads {
    return _threads.where((thread) => thread.type == ThreadType.hq).toList();
  }
  
  // Get project threads (tipe project)
  List<ThreadModel> get projectThreads {
    return _threads.where((thread) => thread.type == ThreadType.project).toList();
  }
  
  // Get root threads (tidak punya parent)
  List<ThreadModel> get rootHqThreads {
    return hqThreads.where((thread) => thread.parentThreadId == null).toList();
  }
  
  // Get root project threads
  List<ThreadModel> get rootProjectThreads {
    return projectThreads.where((thread) => thread.parentThreadId == null).toList();
  }
  
  // Get sub-threads berdasarkan parent id
  List<ThreadModel> getSubThreads(String parentThreadId) {
    return _threads.where((thread) => thread.parentThreadId == parentThreadId).toList();
  }
  
  // Get active thread from data
  ThreadModel? get selectedThread {
    try {
      return _threads.firstWhere((t) => t.id == _selectedThreadId);
    } catch (e) {
      return null;
    }
  }
  
  // Get parent thread name for hierarchical display
  String getParentThreadName(String threadId) {
    final thread = _threads.firstWhere((t) => t.id == threadId, orElse: () => ThreadModel.dummyThreads[0]);
    if (thread.parentThreadId != null) {
      final parentThread = _threads.firstWhere(
        (t) => t.id == thread.parentThreadId, 
        orElse: () => ThreadModel.dummyThreads[0]
      );
      return parentThread.name;
    }
    return thread.name;
  }
  
  // FIXED: Get root thread ID untuk thread management
  String getRootThreadId(String threadId) {
    final thread = _threads.firstWhere((t) => t.id == threadId, orElse: () => ThreadModel.dummyThreads[0]);
    
    print('🔍 DEBUG getRootThreadId: thread=${thread.name}, parentId=${thread.parentThreadId}'); // DEBUG
    
    if (thread.parentThreadId != null) {
      // Recursively find root thread
      final rootId = getRootThreadId(thread.parentThreadId!);
      print('🔍 DEBUG getRootThreadId: recursively found rootId=$rootId'); // DEBUG
      return rootId;
    }
    
    print('🔍 DEBUG getRootThreadId: this is root thread: ${thread.id}'); // DEBUG
    return thread.id;
  }
  
  // FIXED: Get root thread object
  ThreadModel? getRootThread(String threadId) {
    final rootId = getRootThreadId(threadId);
    print('🔍 DEBUG getRootThread: looking for rootId=$rootId'); // DEBUG
    
    try {
      final rootThread = _threads.firstWhere((t) => t.id == rootId);
      print('🔍 DEBUG getRootThread: found root thread=${rootThread.name} (${rootThread.id})'); // DEBUG
      return rootThread;
    } catch (e) {
      print('🔍 DEBUG getRootThread: ERROR finding root thread: $e'); // DEBUG
      return null;
    }
  }
  
  // Get full thread path for breadcrumb
  String getThreadPath(String threadId) {
    final thread = _threads.firstWhere((t) => t.id == threadId, orElse: () => ThreadModel.dummyThreads[0]);
    if (thread.parentThreadId != null) {
      final parentName = getParentThreadName(threadId);
      return '$parentName > ${thread.name}';
    }
    return thread.name;
  }
  
  // Get members for active thread
  List<ThreadMemberModel> get activeMembers {
    return selectedThread?.members ?? [];
  }
  
  // Get members grouped by role
  Map<MemberRole, List<ThreadMemberModel>> get groupedMembers {
    final members = activeMembers;
    return {
      MemberRole.admin: members.where((m) => m.role == MemberRole.admin).toList(),
      MemberRole.custom: members.where((m) => m.role == MemberRole.custom).toList(),
      MemberRole.member: members.where((m) => m.role == MemberRole.member).toList(),
    };
  }
  
  // Toggle member sidebar
  void toggleMembersSidebar() {
    _showMembersSidebar = !_showMembersSidebar;
    notifyListeners();
  }
  
  // Search messages functionality
  void searchMessages(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
  
  // Select thread dengan loading messages
  void selectThread(String threadId) {
    _selectedThreadId = threadId;
    
    // Clear search when switching threads
    _searchQuery = '';
    
    // Load messages jika belum ada
    if (!_threadMessages.containsKey(threadId)) {
      _threadMessages[threadId] = MessageModel.getMinimalDummyMessages(threadId);
    }
    
    notifyListeners();
  }

  // Send text message
  Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    List<MessageAttachment>? attachments,
    String? replyToMessageId,
  }) async {
    if (content.trim().isEmpty && (attachments?.isEmpty ?? true)) return;
    
    final messageId = 'msg-${DateTime.now().millisecondsSinceEpoch}';
    final currentUser = UserModel.currentUser;
    
    final newMessage = MessageModel(
      id: messageId,
      threadId: _selectedThreadId,
      sender: currentUser,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      attachments: attachments,
      replyToMessageId: replyToMessageId,
    );
    
    // Add to local messages
    if (!_threadMessages.containsKey(_selectedThreadId)) {
      _threadMessages[_selectedThreadId] = [];
    }
    _threadMessages[_selectedThreadId]!.add(newMessage);
    
    notifyListeners();
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/threads/$_selectedThreadId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          'content': content,
          'type': type.toString().split('.').last,
          'attachments': attachments?.map((a) => a.toJson()).toList(),
          'reply_to_message_id': replyToMessageId,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final serverMessage = MessageModel.fromJson(responseData);
        
        // Replace local message dengan server message
        final index = _threadMessages[_selectedThreadId]!.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _threadMessages[_selectedThreadId]![index] = serverMessage;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error - bisa tambahkan retry logic atau error state
      rethrow;
    }
    */
  }
  
  // Send image message - FIXED: Handle display untuk local files
  Future<void> sendImageMessage({
    required File imageFile,
    String? caption,
  }) async {
    // Generate attachment dengan placeholder untuk display
    final attachment = MessageAttachment(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      fileName: imageFile.path.split('/').last,
      fileSize: await imageFile.length(),
      fileType: FileType.image,
      url: '/api/placeholder/300/200', // Placeholder image untuk display
      mimeType: 'image/${imageFile.path.split('.').last}',
    );
    
    await sendMessage(
      content: caption ?? 'Image shared',
      type: MessageType.image,
      attachments: [attachment],
    );
    
    // Kode untuk upload file ke server
    /*
    try {
      // Upload file first
      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload'),
      );
      
      uploadRequest.headers['Authorization'] = 'Bearer ${await getToken()}';
      uploadRequest.fields['type'] = 'image';
      uploadRequest.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final uploadResponse = await uploadRequest.send();
      
      if (uploadResponse.statusCode == 200) {
        final uploadResponseData = jsonDecode(await uploadResponse.stream.bytesToString());
        final fileUrl = uploadResponseData['url'];
        
        // Update attachment dengan server URL
        final updatedAttachment = attachment.copyWith(url: fileUrl);
        
        // Update message dengan actual URL
        final messages = _threadMessages[_selectedThreadId];
        if (messages != null) {
          final messageIndex = messages.indexWhere((m) => 
            m.attachments?.any((a) => a.id == attachment.id) ?? false);
          if (messageIndex != -1) {
            final updatedMessage = messages[messageIndex].copyWith(
              attachments: [updatedAttachment],
            );
            messages[messageIndex] = updatedMessage;
            notifyListeners();
          }
        }
      } else {
        throw Exception('Failed to upload image: ${uploadResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
  
  // Send file message - FIXED: Handle display untuk local files
  Future<void> sendFileMessage({
    required File file,
    String? caption,
  }) async {
    // Determine file type based on extension
    final extension = file.path.split('.').last.toLowerCase();
    FileType fileType;
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      fileType = FileType.image;
    } else if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      fileType = FileType.document;
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
      fileType = FileType.audio;
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(extension)) {
      fileType = FileType.video;
    } else {
      fileType = FileType.other;
    }
    
    final attachment = MessageAttachment(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      fileName: file.path.split('/').last,
      fileSize: await file.length(),
      fileType: fileType,
      url: file.path, // Local path untuk sementara
      mimeType: _getMimeType(extension),
    );
    
    await sendMessage(
      content: caption ?? 'File shared: ${attachment.fileName}',
      type: MessageType.file,
      attachments: [attachment],
    );
  }
  
  // Helper untuk mendapatkan MIME type
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  // FIXED: Generate unique sub-thread ID
  String _generateUniqueSubThreadId(String parentId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final counter = ++_subThreadCounter; // Increment counter
    return '${parentId}-sub-${timestamp}-${counter}';
  }

  // FIXED: Create new HQ thread dengan delay untuk mencegah collision
  Future<void> createHQThread({
    required String name,
    String? description,
    List<ThreadMemberModel>? members,
    List<String>? customSubThreads,
  }) async {
    final String threadId = 'hq-${DateTime.now().millisecondsSinceEpoch}';
    
    final newThread = ThreadModel(
      id: threadId,
      name: name,
      type: ThreadType.hq,
      members: members ?? ThreadMemberModel.dummyMembers,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
    );
    
    _threads.add(newThread);
    print('🔧 DEBUG: Root HQ thread created: $threadId'); // DEBUG
    
    // FIXED: Create sub-threads dengan delay untuk mencegah collision
    final subThreadsToCreate = customSubThreads ?? ['lobby', 'announcement', 'brainstorm'];
    
    for (int i = 0; i < subThreadsToCreate.length; i++) {
      String subThreadName = subThreadsToCreate[i];
      
      // FIXED: Add small delay untuk ensure unique timestamp
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
      
      await _createSubThreadInternal(
        parentId: threadId,
        name: subThreadName.startsWith('#') ? subThreadName : '#$subThreadName',
        description: _getDefaultDescription(subThreadName),
        members: newThread.members,
      );
      
      print('🔧 DEBUG: Created sub-thread ${i + 1}/${subThreadsToCreate.length}: $subThreadName');
    }
    
    print('🔧 DEBUG: All sub-threads created for $threadId');
    print('🔧 DEBUG: Total threads after creation: ${_threads.length}');
    
    // Force notifyListeners after all operations
    notifyListeners();
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/threads'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          'name': name,
          'type': 'hq',
          'description': description,
          'members': members?.map((m) => m.user.id).toList() ?? [],
          'sub_threads': customSubThreads ?? ['lobby', 'announcement', 'brainstorm'],
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newThread = ThreadModel.fromJson(responseData);
        _threads.add(newThread);
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to create thread: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }

  // FIXED: Internal method untuk create sub-thread dengan unique ID
  Future<void> _createSubThreadInternal({
    required String parentId,
    required String name,
    String? description,
    List<ThreadMemberModel>? members,
  }) async {
    // Cari parent thread
    final parentThread = _threads.firstWhere((t) => t.id == parentId);
    
    // Tentukan tipe berdasarkan parent
    final threadType = parentThread.type;
    
    // FIXED: Generate unique ID menggunakan helper method
    final threadId = _generateUniqueSubThreadId(parentId);
    
    print('🔧 DEBUG: Creating sub-thread "$name" with ID: $threadId'); // DEBUG
    
    final newThread = ThreadModel(
      id: threadId,
      name: name,
      type: threadType,
      parentThreadId: parentId,
      projectId: parentThread.projectId,
      members: members ?? parentThread.members,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
    );
    
    _threads.add(newThread);
    print('🔧 DEBUG: Sub-thread added to _threads, total: ${_threads.length}'); // DEBUG
  }

  // FIXED: Create sub-thread dengan unique ID generation
  Future<void> createSubThread({
    required String parentId,
    required String name,
    String? description,
    List<ThreadMemberModel>? members,
  }) async {
    print('🔧 DEBUG: Creating individual sub-thread "$name" for parent "$parentId"');
    
    await _createSubThreadInternal(
      parentId: parentId,
      name: name,
      description: description,
      members: members,
    );
    
    print('🔧 DEBUG: Individual sub-thread created');
    print('🔧 DEBUG: Sub-threads for $parentId: ${getSubThreads(parentId).map((t) => '${t.name}(${t.id})').toList()}');
    
    // Force notifyListeners
    notifyListeners();
    
    print('🔧 DEBUG: notifyListeners() called for individual sub-thread creation');
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/threads'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          'name': name,
          'type': threadType.toString().split('.').last,
          'parent_thread_id': parentId,
          'project_id': parentThread.projectId,
          'description': description,
          'members': members?.map((m) => m.user.id).toList() ?? [],
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newThread = ThreadModel.fromJson(responseData);
        _threads.add(newThread);
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to create sub-thread: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }

  // Helper untuk default description
  String _getDefaultDescription(String subThreadName) {
    final name = subThreadName.toLowerCase();
    if (name.contains('lobby')) return 'General discussion';
    if (name.contains('announcement')) return 'Important announcements';
    if (name.contains('brainstorm')) return 'Ideas and brainstorming';
    return 'Thread discussion';
  }

  // Update member role in thread
  Future<void> updateMemberRole({
    required String threadId,
    required String userId,
    required MemberRole role,
    String? customRole,
    Color? roleColor,
  }) async {
    // Cari thread
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex == -1) return;
    
    // Cari member dalam thread
    final memberIndex = _threads[threadIndex].members.indexWhere((m) => m.user.id == userId);
    if (memberIndex == -1) return;
    
    // Update role
    final updatedMember = _threads[threadIndex].members[memberIndex].copyWith(
      role: role,
      customRole: customRole,
      roleColor: roleColor,
    );
    
    // Update thread dengan member baru
    final updatedMembers = List<ThreadMemberModel>.from(_threads[threadIndex].members);
    updatedMembers[memberIndex] = updatedMember;
    
    _threads[threadIndex] = _threads[threadIndex].copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/threads/$threadId/members/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: jsonEncode({
          'role': role.toString().split('.').last,
          'custom_role': customRole,
          'role_color': roleColor?.value,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update member role: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
  
  // Ambil data thread dari server
  Future<void> fetchThreads() async {
    // Untuk sementara, gunakan data dummy
    _threads = ThreadModel.dummyThreads;
    
    // Load minimal dummy messages untuk semua thread
    for (final thread in _threads) {
      _threadMessages[thread.id] = MessageModel.getMinimalDummyMessages(thread.id);
    }
    
    notifyListeners();
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/threads'),
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _threads = data.map((item) => ThreadModel.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch threads: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
  
  // Ambil messages untuk thread tertentu
  Future<void> fetchThreadMessages(String threadId) async {
    // Untuk sementara, gunakan data dummy
    if (!_threadMessages.containsKey(threadId)) {
      _threadMessages[threadId] = MessageModel.getMinimalDummyMessages(threadId);
      notifyListeners();
    }
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/threads/$threadId/messages'),
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final messages = data.map((item) => MessageModel.fromJson(item)).toList();
        _threadMessages[threadId] = messages;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
  
  // Ambil data anggota thread dari server
  Future<void> fetchThreadMembers(String threadId) async {
    // Untuk sementara, data sudah terintegrasi dengan thread
    notifyListeners();
    
    // Kode untuk integrasi dengan API PHP
    /*
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/threads/$threadId/members'),
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final members = data.map((item) => ThreadMemberModel.fromJson(item)).toList();
        
        // Update thread dengan members baru
        final threadIndex = _threads.indexWhere((t) => t.id == threadId);
        if (threadIndex != -1) {
          _threads[threadIndex] = _threads[threadIndex].copyWith(members: members);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to fetch thread members: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
  
  // Delete message (soft delete - akan disembunyikan dari UI)
  Future<void> deleteMessage(String messageId) async {
    final messages = _threadMessages[_selectedThreadId];
    if (messages != null) {
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        // Remove dari local state
        messages.removeAt(messageIndex);
        notifyListeners();
        
        // Kode untuk delete di server
        /*
        try {
          final response = await http.delete(
            Uri.parse('${ApiConfig.baseUrl}/messages/$messageId'),
            headers: {
              'Authorization': 'Bearer ${await getToken()}',
            },
          );
          
          if (response.statusCode != 200) {
            throw Exception('Failed to delete message: ${response.statusCode}');
          }
        } catch (e) {
          // Rollback jika gagal
          messages.insert(messageIndex, deletedMessage);
          notifyListeners();
          rethrow;
        }
        */
      }
    }
  }
  
  // Edit message
  Future<void> editMessage(String messageId, String newContent) async {
    final messages = _threadMessages[_selectedThreadId];
    if (messages != null) {
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final originalMessage = messages[messageIndex];
        
        // Update local message
        messages[messageIndex] = originalMessage.copyWith(
          content: newContent,
          isEdited: true,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        
        // Kode untuk update di server
        /*
        try {
          final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/messages/$messageId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await getToken()}',
            },
            body: jsonEncode({
              'content': newContent,
            }),
          );
          
          if (response.statusCode != 200) {
            throw Exception('Failed to edit message: ${response.statusCode}');
          }
        } catch (e) {
          // Rollback jika gagal
          messages[messageIndex] = originalMessage;
          notifyListeners();
          rethrow;
        }
        */
      }
    }
  }
}