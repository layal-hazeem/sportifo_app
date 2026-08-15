
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/helpers/dialog_helper.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/utils/url_fixer.dart';
import '../../data/models/message_model.dart';
import '../view_model/chat_detail_cubit.dart';
import '../view_model/chat_detail_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/message_date_separator.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String otherParticipantName;
  final String? otherParticipantImage;
  final bool canSend;

  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
    required this.otherParticipantName,
    this.otherParticipantImage,
    this.canSend = true,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
   late final ChatDetailCubit _cubit;
  int? _currentUserId;

  List<XFile> _selectedImages = [];

  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ChatDetailCubit>();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _loadUserId();
    _initAsync();
_setupConnectivityListener();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        final shouldShow = maxScroll > 0 && (maxScroll - currentScroll) > 200;
        if (shouldShow != _showScrollButton) {
          setState(() {
            _showScrollButton = shouldShow;
          });
        }
      }
    });
  }

  void _loadUserId() {
    final localStorage = getIt<LocalStorage>();
    final dynamic rawUserId = localStorage.getUserId();
    if (rawUserId == null) {
      _currentUserId = null;
    } else if (rawUserId is int) {
      _currentUserId = rawUserId;
    } else if (rawUserId is String) {
      _currentUserId = int.tryParse(rawUserId);
    } else if (rawUserId is num) {
      _currentUserId = rawUserId.toInt();
    } else {
      _currentUserId = int.tryParse(rawUserId.toString());
    }
  }

Future<void> _initAsync() async {
  final cubit = context.read<ChatDetailCubit>();
  cubit.setCanSend(widget.canSend);
  
  // 1. حمل الرسائل الأولى
  await cubit.fetchMessages(widget.conversationId);
  
  // 2. اشترك بالـ WebSocket (بعد ما يكون فيه messages)
  await cubit.subscribeToChannel(widget.conversationId);
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollToBottom(animated: false);
  });
}

void _setupConnectivityListener() {
  Connectivity().onConnectivityChanged.listen((result) {
    if (result != ConnectivityResult.none) {
      // 🔥 عند رجوع النت، أعد محاولة إرسال المعلقات و resync
      context.read<ChatDetailCubit>().checkConnectivityAndRetry();
    }
  });
}
  @override
void dispose() {
  _cubit.unsubscribe();
  // 🔥 إلغاء الاشتراك عند الخروج
  context.read<ChatDetailCubit>().unsubscribe();
  _messageController.dispose();
  _scrollController.dispose();
  super.dispose();
}

  // 🔥 دالة التمرير مع اختيار الحركة أو القفز المباشر
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // 🔥 القفز المباشر بدون حركة
      _scrollController.jumpTo(maxExtent);
    }
  }

  bool _isSentByMe(MessageModel message) {
    if (_currentUserId == null) return false;
    return message.senderId == _currentUserId ||
        message.senderId.toString() == _currentUserId.toString();
  }

  String _getDateSeparator(DateTime messageDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(messageDate.year, messageDate.month, messageDate.day);

    if (msgDate == today) return 'اليوم';
    if (msgDate == yesterday) return 'أمس';
    return '${msgDate.day}/${msgDate.month}/${msgDate.year}';
  }

  void _showMessageDetails(MessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تفاصيل الرسالة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBtn,
                ),
              ),
              const Divider(height: 24),
              if (message.sentAt != null)
                _detailRow(' وقت الإرسال', '${message.sentAt!['date']} ${message.sentAt!['time']}'),
              if (message.deliveredAt != null)
                _detailRow('وقت التوصيل', '${message.deliveredAt!['date']} ${message.deliveredAt!['time']}'),
              if (message.readAt != null)
                _detailRow(' وقت القراءة', '${message.readAt!['date']} ${message.readAt!['time']}'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int messageId, String clientUuid) {
    DialogHelper.showCustomDialog(
      context: context,
      title: 'حذف الرسالة',
      message: 'هل أنت متأكد من حذف هذه الرسالة؟ لا يمكن التراجع عن هذا الإجراء.',
      type: DialogType.warning,
      confirmBtnText: 'حذف',
      onConfirm: () {
        context.read<ChatDetailCubit>().deleteMessage(
              widget.conversationId,
              messageId,
              clientUuid,
            );
      },
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (images.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يمكنك اختيار 5 صور كحد أقصى'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() {
        _selectedImages = images;
      });
    }
  }

  void _clearImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  Future<List<XFile>> _compressImages(List<XFile> images) async {
    List<XFile> compressed = [];
    final tempDir = await getTemporaryDirectory();

    for (var image in images) {
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        rotate: 0,
      );
      if (result != null) {
        compressed.add(XFile(result.path));
      } else {
        compressed.add(image);
      }
    }
    return compressed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherParticipantImage != null
                  ? NetworkImage(UrlFixer.image(widget.otherParticipantImage!)!)
                  : null,
              backgroundColor: Colors.white24,
              child: widget.otherParticipantImage == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherParticipantName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: BlocListener<ChatDetailCubit, ChatDetailState>(
        listener: (context, state) {
          if (state is ChatDetailLoaded) {
            // 🔥 عند تحميل الرسائل أو إضافة جديدة، نستخدم animated: true
            // ليعطي حركة سلسة عند الإرسال
            _scrollToBottom(animated: true);
          }
          if (state is ChatDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<ChatDetailCubit, ChatDetailState>(
          builder: (context, state) {
            if (state is ChatDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBtn,
                ),
              );
            }

            if (state is ChatDetailError && state is! ChatDetailLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ChatDetailCubit>()
                            .fetchMessages(widget.conversationId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة محاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBtn,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ChatDetailLoaded) {
              final messages = state.messages;

              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد رسائل حتى الآن',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ابدأ المحادثة الآن',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isSentByMe = _isSentByMe(message);

                                  String? dateSeparator;
                                  if (index == 0) {
                                    dateSeparator = _getDateSeparator(message.getDateTime());
                                  } else {
                                    final previousMessage = messages[index - 1];
                                    if (message.getDateTime().day !=
                                        previousMessage.getDateTime().day) {
                                      dateSeparator = _getDateSeparator(message.getDateTime());
                                    }
                                  }

                                  return Column(
                                    children: [
                                      if (dateSeparator != null)
                                        MessageDateSeparator(date: dateSeparator),
                                      MessageBubble(
                                        message: message,
                                        isSentByCurrentUser: isSentByMe,
                                        canDelete: isSentByMe,
                                        onDelete: () {
                                          _showDeleteConfirmation(
                                            message.id,
                                            message.clientUuid,
                                          );
                                        },
                                        onShowDetails: () {
                                          _showMessageDetails(message);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      if (_selectedImages.isNotEmpty)
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      MessageInputField(
                        controller: _messageController,
                        enabled: widget.canSend,
                        isLoading: state.isSending,
                        disabledReason: widget.canSend
                            ? null
                            : 'يمكن للمدرب فقط إرسال رسائل في هذا الاشتراك',
                        onImageTap: _pickImages,
                        onSend: () async {
                          final text = _messageController.text.trim();

                          if (text.isEmpty && _selectedImages.isEmpty) return;

                          if (_currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('خطأ: لم يتم تحديد المستخدم الحالي'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final List<XFile> compressedImages = await _compressImages(_selectedImages);
                          final List<String> imagePaths = compressedImages.map((xfile) => xfile.path).toList();

                          context.read<ChatDetailCubit>().sendMessage(
                                widget.conversationId,
                                text,
                                _currentUserId!,
                                'أنت',
                                null,
                                imagePaths: imagePaths,
                              );

                          _messageController.clear();
                          _clearImages();
                        },
                      ),
                    ],
                  ),
                  if (_showScrollButton)
                    Positioned(
                      bottom: 120,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color(0xFFFF9800),
                        onPressed: () => _scrollToBottom(animated: true),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

