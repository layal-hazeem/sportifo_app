import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/home/presentation/widgets/empty_state_widget.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Expects the FULL client list (not pre-filtered by `hasPlan`) — otherwise
/// the "needs a plan" badge below can never render, since every item would
/// already have `hasPlan == true`.
class ClientsPreviewSection extends StatelessWidget {
  final List<UsersSubscribedModel> clients;
  final VoidCallback onSeeAllTap;
  final ValueChanged<UsersSubscribedModel> onClientTap;

  const ClientsPreviewSection({
    super.key,
    required this.clients,
    required this.onSeeAllTap,
    required this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.yourTrainees,
              style: TextStyle(
                fontSize: AppSizes.labelFontSize + 2,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            if (clients.isNotEmpty)
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    l10n.see_all,
                    style: TextStyle(
                      fontSize: AppSizes.hintFontSize,
                      color: AppColors.linkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (clients.isEmpty)
          EmptyStateWidget(
            icon: Icons.people_outline_rounded,
            message: l10n.noTraineesYet,
            height: 95,
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final client = clients[index];
                return _ClientAvatarItem(
                  client: client,
                  onTap: () => onClientTap(client),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ClientAvatarItem extends StatelessWidget {
  final UsersSubscribedModel client;
  final VoidCallback onTap;

  const _ClientAvatarItem({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool hasPlan = client.hasPlan ?? false;
    final String name = '${client.firstName ?? ''} ${client.lastName ?? ''}'
        .trim();
    final String displayName = name.isEmpty ? 'Unknown name' : name;

    return Semantics(
      button: true,
      label:
          '$displayName, ${hasPlan ? l10n.hasAnActivePlan : l10n.needs_a_plan}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: context.backgroundColor,
                    backgroundImage:
                        (client.profilePic != null &&
                            client.profilePic!.isNotEmpty)
                        ? NetworkImage(client.profilePic!)
                        : null,
                    child:
                        (client.profilePic == null ||
                            client.profilePic!.isEmpty)
                        ? Icon(Icons.person, color: AppColors.hintText)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: hasPlan ? Colors.green : AppColors.primaryBtn,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        hasPlan ? Icons.check : Icons.priority_high_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: context.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
