import 'dart:async';
import 'dart:math' as dev;

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
import 'package:sportifo_app/features/ai_chat/presentation/widgets/typing_indicator.dart';
import 'package:sportifo_app/l10n/app_localizations.dart'; // ← جديد
import '../../data/models/message_model.dart';
import '../view_model/chat_detail_cubit.dart';
import '../view_model/chat_detail_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/message_date_separator.dart';
import 'package:sportifo_app/core/helpers/snack_bar_utils.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String otherParticipantName;
  final String? otherParticipantImage;
  final int? otherParticipantGender;
  final String? subscriptionType;

  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
    required this.otherParticipantName,
    this.otherParticipantGender,
    this.otherParticipantImage,
    this.subscriptionType,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final ChatDetailCubit _cubit;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  int? _currentUserId;
  bool _initialScrollDone = false;

  List<XFile> _selectedImages = [];
  bool _showScrollButton = false;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _initialScrollDone = false;
    _cubit = context.read<ChatDetailCubit>();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _loadUserId();
    _calculateCanSend();
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


  void _calculateCanSend() {
  final localStorage = getIt<LocalStorage>();
  final userRole = localStorage.getRole()?.toLowerCase();
  final type = widget.subscriptionType?.toLowerCase();
print ('🔍 userRole = $userRole');
print ('🔍 subscriptionType = $type');
 

  if (userRole == 'coach') {
    _canSend = true;
  } else {
    _canSend = type == 'gold';
  }
  print('🔍 _canSend = $_canSend');
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
    _cubit.setCanSend(_canSend);
    if (_currentUserId != null) _cubit.setCurrentUserId(_currentUserId!);
    await _cubit.fetchMessages(widget.conversationId);
    await _cubit.subscribeToChannel(widget.conversationId);
    _cubit.subscribeToChannel(widget.conversationId);
    _cubit.setScreenActive(true);
  }

  void _setupConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && mounted) {
        _cubit.checkConnectivityAndRetry();
      }
    });
  }

  @override
  void dispose() {
    _cubit.setScreenActive(false);
    _connectivitySub?.cancel();
    _cubit.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxExtent);
      }
    });
  }

  bool _isSentByMe(MessageModel message) {
    if (_currentUserId == null) return false;
    return message.senderId == _currentUserId ||
        message.senderId.toString() == _currentUserId.toString();
  }

  String _getDateSeparator(DateTime messageDate) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(
      messageDate.year,
      messageDate.month,
      messageDate.day,
    );

    if (msgDate == today) return l10n.today;
    if (msgDate == yesterday) return l10n.yesterday;
    return '${msgDate.day}/${msgDate.month}/${msgDate.year}';
  }

 void _showMessageDetails(MessageModel message) {
  final l10n = AppLocalizations.of(context)!;

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
              l10n.messageDetails,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBtn,
              ),
            ),
            const Divider(height: 24),
            if (message.sentAt != null)
              _detailRow(
                l10n.sentAt,
                '${message.sentAt!['date']} ${message.sentAt!['time']}',
              ),
            if (message.deliveredAt != null)
              _detailRow(
                l10n.deliveredAt,
                '${message.deliveredAt!['date']} ${message.deliveredAt!['time']}',
              ),
            if (message.readAt != null)
              _detailRow(
                l10n.readAt,
                '${message.readAt!['date']} ${message.readAt!['time']}',
              ),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (images.length > 5) {
        AppSnackBar.show(
          context,
          message: l10n.max5Images,
          type: SnackBarType.warning,
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
void _showDeleteConfirmation(int? messageId, String? clientUuid) {
    final l10n = AppLocalizations.of(context)!;

    DialogHelper.showCustomDialog(
      context: context,
      title: l10n.deleteMessageTitle ,
      message: l10n.deleteMessageConfirmation ,
      type: DialogType.warning,
      confirmBtnText: l10n.delete,
      onConfirm: () {
        context.read<ChatDetailCubit>().deleteMessage(
          widget.conversationId,
          messageId ?? -1,       
          clientUuid ?? '',
        );
      },
    );
  }
  Future<List<XFile>> _compressImages(List<XFile> images) async {
    List<XFile> compressed = [];
    final tempDir = await getTemporaryDirectory();

    for (var image in images) {
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
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
    final l10n = AppLocalizations.of(context)!; // ← نفس أسلوب LoginScreen

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/chat_background1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF3E0).withValues(alpha: 0.0),
          elevation: 0,
          titleSpacing: 8,
          leadingWidth: 56,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF57C00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          title: Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 45,
              top: 6,
              bottom: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                      CircleAvatar(
                  radius: 17,
                  backgroundImage: widget.otherParticipantImage != null
                      ? NetworkImage(
                          UrlFixer.image(widget.otherParticipantImage!)!,
                        )
                      : (widget.otherParticipantGender == 1
                          ? const AssetImage('assets/images/male.jpg')
                          : const AssetImage('assets/images/female.jpg'))
                          as ImageProvider,
                  backgroundColor: Colors.white24,
                  // child محذوف لأن backgroundImage موجود
                ),
                const SizedBox(width: 18),
                Text(
                  widget.otherParticipantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
        ),
        body: BlocListener<ChatDetailCubit, ChatDetailState>(
          listener: (context, state) {
            if (state is ChatDetailLoaded && !_initialScrollDone) {
              _initialScrollDone = true;
              _scrollToBottom(animated: false);
            }
            if (state is ChatDetailError) {
              AppSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            }
          },
          child: BlocBuilder<ChatDetailCubit, ChatDetailState>(
            builder: (context, state) {
              if (state is ChatDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBtn),
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
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _cubit.fetchMessages(widget.conversationId);
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
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
                                        l10n.noMessagesYet,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.startConversation,
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
                                  itemCount:
                                      messages.length +
                                      (state.typingUserId != null ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (state.typingUserId != null &&
                                        index == messages.length) {
                                      return const TypingIndicator();
                                    }
                                    final message = messages[index];
                                    final isSentByMe = _isSentByMe(message);

                                    String? dateSeparator;
                                    if (index == 0) {
                                      dateSeparator = _getDateSeparator(
                                        message.getDateTime(),
                                      );
                                    } else {
                                      final previousMessage =
                                          messages[index - 1];
                                      if (message.getDateTime().day !=
                                          previousMessage.getDateTime().day) {
                                        dateSeparator = _getDateSeparator(
                                          message.getDateTime(),
                                        );
                                      }
                                    }

                                    return Column(
                                      children: [
                                        if (dateSeparator != null)
                                          MessageDateSeparator(
                                            date: dateSeparator,
                                          ),
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
                                          onRetry: message.status == 'failed'
                                              ? () => _cubit.retryMessage(
                                                  message.clientUuid,
                                                )
                                              : null,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        if (_selectedImages.isNotEmpty)
                          Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
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
                          enabled: _canSend,
                          isLoading: state.isSending,
                          disabledReason: _canSend
                              ? null
                              : l10n.trainerOnlyCanSend,
                          onImageTap: _pickImages,
                          onChanged: (text) {
                            if (text.isNotEmpty && _currentUserId != null) {
                              _cubit.sendTypingNotification(
                                widget.conversationId,
                                _currentUserId!,
                              );
                            }
                          },
                          onSend: () async {
                            final text = _messageController.text.trim();

                            if (text.isEmpty && _selectedImages.isEmpty) return;

                            if (_currentUserId == null) {
                              AppSnackBar.show(
                                context,
                                message: l10n.errorUserNotFound,
                                type: SnackBarType.error,
                              );
                              return;
                            }

                            final List<XFile> compressedImages =
                                await _compressImages(_selectedImages);
                            final List<String> imagePaths = compressedImages
                                .map((xfile) => xfile.path)
                                .toList();

                            _cubit.sendMessage(
                              widget.conversationId,
                              text,
                              _currentUserId!,
                              l10n.you,
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
                          backgroundColor: Colors.white,
                          onPressed: () => _scrollToBottom(animated: true),
                          child: const Icon(
                            Icons.arrow_downward,
                            color: Color(0xFFF57C00),
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
      ),
    );
  }
}