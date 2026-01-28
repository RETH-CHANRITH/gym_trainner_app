import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:gym_trainer/app/modules/favourite/views/favourite_view.dart';
import 'package:gym_trainer/app/modules/profile/views/profile_screen.dart';
import 'package:gym_trainer/app/modules/messaging/views/messaging_screen.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
	const HomeView({super.key});

	// App Colors
	static const Color primaryPurple = Color(0xFF896CFE);
	static const Color darkBg = Color(0xFF101014);
	static const Color cardBg = Color(0xFF181824);
	static const Color borderColor = Color(0xFF2D2838);
	static const Color accentYellow = Color(0xFFE2F163);
	static const Color lightPurple = Color(0xFFB3A0FF);
	static const Color glassBg = Color(0x33FFFFFF);

	@override
	Widget build(BuildContext context) {
		final iconList = [
			Icons.home_rounded,
			Icons.favorite_rounded,
			Icons.message_rounded,
			Icons.person_rounded,
		];

		final pages = [
			_buildHomeTab(),
			const FavouriteView(),
			const MessagingScreen(),
			const ProfileScreen(),
		];

		return Obx(
			() => Scaffold(
				backgroundColor: darkBg,
				extendBody: true,
				body: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [Color(0xFF181824), Color(0xFF23233A), Color(0xFF101014)],
						),
					),
					child: SafeArea(child: pages[controller.currentIndex.value]),
				),
				bottomNavigationBar: AnimatedBottomNavigationBar.builder(
					backgroundColor: cardBg.withOpacity(0.95),
					itemCount: iconList.length,
					tabBuilder: (int index, bool isActive) {
						return Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(
									iconList[index],
									size: 28,
									color: isActive ? accentYellow : Colors.white.withOpacity(0.4),
								),
								const SizedBox(height: 4),
								AnimatedContainer(
									duration: const Duration(milliseconds: 200),
									width: isActive ? 8 : 0,
									height: isActive ? 8 : 0,
									decoration: BoxDecoration(
										color: accentYellow,
										shape: BoxShape.circle,
										boxShadow: isActive
												? [BoxShadow(color: accentYellow.withOpacity(0.5), blurRadius: 8)]
												: [],
									),
								),
							],
						);
					},
					activeIndex: controller.currentIndex.value,
					gapLocation: GapLocation.center,
					notchSmoothness: NotchSmoothness.softEdge,
					leftCornerRadius: 24,
					rightCornerRadius: 24,
					height: 74,
					splashColor: primaryPurple.withOpacity(0.13),
					splashSpeedInMilliseconds: 300,
					onTap: controller.changeTab,
				),
			),
		);
	}

	// Home tab content (was previously the HomeView body)
	Widget _buildHomeTab() {
		return SingleChildScrollView(
			physics: const BouncingScrollPhysics(),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const SizedBox(height: 16),
						_buildHeader(),
						const SizedBox(height: 24),
						_buildGreeting(),
						const SizedBox(height: 20),
						_buildSearchBar(),
						const SizedBox(height: 24),
						_buildCategoryTabs(),
						const SizedBox(height: 28),
						_buildUpcomingSessionsSection(),
						_buildSectionHeader('Top Trainers', () {}),
						const SizedBox(height: 16),
						_buildTrainersGrid(),
						const SizedBox(height: 28),
						_buildQuickActions(),
						const SizedBox(height: 28),
						_buildSpecialOfferCard(),
						const SizedBox(height: 24),
					],
				),
			),
		);
	}

	// --- All helper widgets from the original HomeScreen pasted below ---
	Widget _buildHeader() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				// Profile avatar (modernized)
				Container(
					width: 54,
					height: 54,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(18),
						boxShadow: [
							BoxShadow(
								color: primaryPurple.withOpacity(0.18),
								blurRadius: 12,
								offset: const Offset(0, 4),
							),
						],
						gradient: const LinearGradient(
							colors: [Color(0xFFB3A0FF), Color(0xFF896CFE)],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
					),
					child: ClipRRect(
						borderRadius: BorderRadius.circular(18),
						child: Image.asset(
							'assets/images/user_avatar.png',
							fit: BoxFit.cover,
							errorBuilder: (context, error, stackTrace) => const Center(
								child: Text(
									'M',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w700,
									),
								),
							),
						),
					),
				),
				Row(
					children: [
						_buildMessageIcon(),
						const SizedBox(width: 12),
						_buildNotificationIcon(),
					],
				),
			],
		);
	}

	Widget _buildMessageIcon() {
		return GestureDetector(
			onTap: () => controller.navigateToMessages(),
			child: Container(
				width: 44,
				height: 44,
				decoration: BoxDecoration(
					color: cardBg,
					borderRadius: BorderRadius.circular(12),
					border: Border.all(color: borderColor),
				),
				child: Stack(
					alignment: Alignment.center,
					children: [
						const Icon(
							Icons.chat_bubble_outline_rounded,
							color: Colors.white,
							size: 22,
						),
						Obx(() {
							final badge = controller.unreadMessagesCount.value;
							if (badge <= 0) return const SizedBox.shrink();
							return Positioned(
								top: 6,
								right: 6,
								child: Container(
									width: 16,
									height: 16,
									decoration: const BoxDecoration(
										color: accentYellow,
										shape: BoxShape.circle,
									),
									child: Center(
										child: Text(
											badge > 9 ? '9+' : '$badge',
											style: const TextStyle(
												color: darkBg,
												fontSize: 9,
												fontWeight: FontWeight.bold,
											),
										),
									),
								),
							);
						}),
					],
				),
			),
		);
	}

	Widget _buildNotificationIcon() {
		return GestureDetector(
			onTap: () => controller.navigateToNotifications(),
			child: Container(
				width: 44,
				height: 44,
				decoration: BoxDecoration(
					color: cardBg,
					borderRadius: BorderRadius.circular(12),
					border: Border.all(color: borderColor),
				),
				child: Stack(
					alignment: Alignment.center,
					children: [
						const Icon(
							Icons.notifications_none_rounded,
							color: Colors.white,
							size: 22,
						),
						Obx(() {
							final badge = controller.unreadNotificationsCount.value;
							if (badge <= 0) return const SizedBox.shrink();
							return Positioned(
								top: 6,
								right: 6,
								child: Container(
									width: 16,
									height: 16,
									decoration: const BoxDecoration(
										color: accentYellow,
										shape: BoxShape.circle,
									),
									child: Center(
										child: Text(
											badge > 9 ? '9+' : '$badge',
											style: const TextStyle(
												color: darkBg,
												fontSize: 9,
												fontWeight: FontWeight.bold,
											),
										),
									),
								),
							);
						}),
					],
				),
			),
		);
	}

	Widget _buildGreeting() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Welcome back,',
					style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
				),
				const SizedBox(height: 4),
				const Text(
					'Mostafa 👋',
					style: TextStyle(
						color: primaryPurple,
						fontSize: 26,
						fontWeight: FontWeight.bold,
					),
				),
				const SizedBox(height: 6),
				Text(
					'Find your perfect trainer today',
					style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
				),
			],
		);
	}

	Widget _buildSearchBar() {
		return GestureDetector(
			onTap: () => controller.navigateToSearch(),
			child: Container(
				padding: const EdgeInsets.all(14),
				decoration: BoxDecoration(
					color: cardBg,
					borderRadius: BorderRadius.circular(16),
					border: Border.all(color: borderColor),
				),
				child: Row(
					children: [
						Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 22),
						const SizedBox(width: 12),
						Expanded(
							child: Text(
								'Search trainers...',
								style: TextStyle(
									color: Colors.white.withOpacity(0.4),
									fontSize: 15,
								),
							),
						),
						Container(
							padding: const EdgeInsets.all(8),
							decoration: BoxDecoration(
								color: primaryPurple,
								borderRadius: BorderRadius.circular(10),
							),
							child: const Icon(Icons.tune, color: Colors.white, size: 16),
						),
					],
				),
			),
		);
	}

	Widget _buildCategoryTabs() {
		final categories = [
			{'icon': Icons.fitness_center, 'label': 'Strength'},
			{'icon': Icons.self_improvement, 'label': 'Yoga'},
			{'icon': Icons.directions_run, 'label': 'Cardio'},
			{'icon': Icons.sports_martial_arts, 'label': 'Boxing'},
		];

		return SizedBox(
			height: 80,
			child: ListView.separated(
				scrollDirection: Axis.horizontal,
				itemCount: categories.length,
				separatorBuilder: (_, __) => const SizedBox(width: 12),
				itemBuilder: (context, index) {
					return _buildCategoryItem(
						categories[index]['icon'] as IconData,
						categories[index]['label'] as String,
						index,
					);
				},
			),
		);
	}

	Widget _buildCategoryItem(IconData icon, String label, int index) {
		return Obx(() {
			final isSelected = controller.selectedCategoryIndex.value == index;
			return GestureDetector(
				onTap: () => controller.selectCategory(index),
				child: AnimatedContainer(
					duration: const Duration(milliseconds: 200),
					width: 80,
					decoration: BoxDecoration(
						color: isSelected ? primaryPurple : cardBg,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(color: isSelected ? primaryPurple : borderColor),
					),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								icon,
								color: isSelected ? Colors.white : lightPurple,
								size: 26,
							),
							const SizedBox(height: 6),
							Text(
								label,
								style: TextStyle(
									color: isSelected ? Colors.white : Colors.white70,
									fontSize: 11,
									fontWeight: FontWeight.w500,
								),
							),
						],
					),
				),
			);
		});
	}

	Widget _buildUpcomingSessionsSection() {
		return Obx(() {
			if (controller.upcomingBookings.isEmpty) return const SizedBox.shrink();

			return Column(
				children: [
					_buildSectionHeader('Upcoming Sessions', () {}),
					const SizedBox(height: 14),
					...controller.upcomingBookings
							.take(2)
							.map(
								(booking) => Padding(
									padding: const EdgeInsets.only(bottom: 12),
									child: _buildSessionCard(booking),
								),
							),
					const SizedBox(height: 16),
				],
			);
		});
	}

	Widget _buildSessionCard(Map<String, dynamic> booking) {
		final isConfirmed = booking['status'] == 'confirmed';

		return GestureDetector(
			onTap: () => controller.navigateToBookingDetails(booking['id']),
			child: Container(
				padding: const EdgeInsets.all(16),
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors:
								isConfirmed
										? [primaryPurple, const Color(0xFF6B4EE6)]
										: [cardBg, const Color(0xFF252530)],
					),
					borderRadius: BorderRadius.circular(18),
					border: isConfirmed ? null : Border.all(color: borderColor),
				),
				child: Row(
					children: [
						Container(
							width: 50,
							height: 50,
							decoration: BoxDecoration(
								color: Colors.white.withOpacity(isConfirmed ? 0.2 : 0.1),
								borderRadius: BorderRadius.circular(12),
							),
							child: Icon(
								Icons.fitness_center,
								color: isConfirmed ? Colors.white : lightPurple,
								size: 24,
							),
						),
						const SizedBox(width: 14),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										booking['sessionType'] ?? '',
										style: const TextStyle(
											color: Colors.white,
											fontSize: 15,
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 3),
									Text(
										'with ${booking['trainerName']}',
										style: TextStyle(
											color: Colors.white.withOpacity(0.7),
											fontSize: 12,
										),
									),
								],
							),
						),
						Column(
							crossAxisAlignment: CrossAxisAlignment.end,
							children: [
								Container(
									padding: const EdgeInsets.symmetric(
										horizontal: 8,
										vertical: 3,
									),
									decoration: BoxDecoration(
										color: isConfirmed ? accentYellow : lightPurple,
										borderRadius: BorderRadius.circular(6),
									),
									child: Text(
										booking['date'] ?? '',
										style: TextStyle(
											color: isConfirmed ? darkBg : Colors.white,
											fontSize: 11,
											fontWeight: FontWeight.w600,
										),
									),
								),
								const SizedBox(height: 4),
								Text(
									booking['time'] ?? '',
									style: const TextStyle(
										color: Colors.white,
										fontSize: 13,
										fontWeight: FontWeight.w500,
									),
								),
							],
						),
					],
				),
			),
		);
	}

	Widget _buildSectionHeader(String title, VoidCallback onTap) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(
					title,
					style: const TextStyle(
						color: accentYellow,
						fontSize: 17,
						fontWeight: FontWeight.w600,
					),
				),
				GestureDetector(
					onTap: onTap,
					child: const Row(
						children: [
							Text(
								'View All',
								style: TextStyle(color: lightPurple, fontSize: 13),
							),
							SizedBox(width: 4),
							Icon(Icons.arrow_forward_ios, color: lightPurple, size: 11),
						],
					),
				),
			],
		);
	}

	Widget _buildTrainersGrid() {
		return SizedBox(
			height: 220,
			child: Obx(
				() => ListView.separated(
					scrollDirection: Axis.horizontal,
					itemCount: controller.featuredTrainers.length,
					separatorBuilder: (_, __) => const SizedBox(width: 14),
					itemBuilder:
							(_, index) =>
									_buildTrainerCard(controller.featuredTrainers[index]),
				),
			),
		);
	}

	Widget _buildTrainerCard(Map<String, dynamic> trainer) {
		final isAvailable = trainer['isAvailable'] == true;

		return GestureDetector(
			onTap: () => controller.navigateToTrainerDetails(trainer['id']),
			child: Container(
				width: 160,
				decoration: BoxDecoration(
					color: cardBg,
					borderRadius: BorderRadius.circular(18),
					border: Border.all(color: borderColor),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Image
						Stack(
							children: [
								ClipRRect(
									borderRadius: const BorderRadius.vertical(
										top: Radius.circular(18),
									),
									child: Container(
										height: 100,
										width: double.infinity,
										color: borderColor,
										child: Image.network(
											trainer['image'] ?? '',
											fit: BoxFit.cover,
											errorBuilder:
													(_, __, ___) => const Center(
														child: Icon(
															Icons.person,
															color: primaryPurple,
															size: 40,
														),
													),
										),
									),
								),
								Positioned(
									top: 8,
									right: 8,
									child: Container(
										padding: const EdgeInsets.symmetric(
											horizontal: 6,
											vertical: 3,
										),
										decoration: BoxDecoration(
											color: isAvailable ? Colors.green : Colors.grey,
											borderRadius: BorderRadius.circular(6),
										),
										child: Text(
											isAvailable ? 'Available' : 'Busy',
											style: const TextStyle(
												color: Colors.white,
												fontSize: 9,
												fontWeight: FontWeight.w600,
											),
										),
									),
								),
							],
						),
						// Info
						Padding(
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										trainer['name'] ?? '',
										style: const TextStyle(
											color: Colors.white,
											fontSize: 14,
											fontWeight: FontWeight.w600,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									const SizedBox(height: 2),
									Text(
										trainer['specialty'] ?? '',
										style: const TextStyle(color: lightPurple, fontSize: 11),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									const SizedBox(height: 8),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Row(
												children: [
													const Icon(Icons.star, color: accentYellow, size: 14),
													const SizedBox(width: 3),
													Text(
														'${trainer['rating']}',
														style: const TextStyle(
															color: Colors.white,
															fontSize: 12,
															fontWeight: FontWeight.w500,
														),
													),
												],
											),
											Text(
												'\$${trainer['pricePerHour']}/h',
												style: const TextStyle(
													color: accentYellow,
													fontSize: 12,
													fontWeight: FontWeight.w600,
												),
											),
										],
									),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildQuickActions() {
		final actions = [
			{'icon': Icons.calendar_month, 'label': 'Book'},
			{'icon': Icons.history, 'label': 'History'},
			{'icon': Icons.payment, 'label': 'Payment'},
			{'icon': Icons.headset_mic, 'label': 'Support'},
		];

		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children:
					actions.map((action) {
						return GestureDetector(
							onTap: () {},
							child: Container(
								width: 72,
								height: 72,
								decoration: BoxDecoration(
									color: cardBg,
									borderRadius: BorderRadius.circular(16),
									border: Border.all(color: borderColor),
								),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(
											action['icon'] as IconData,
											color: primaryPurple,
											size: 24,
										),
										const SizedBox(height: 6),
										Text(
											action['label'] as String,
											style: const TextStyle(
												color: Colors.white70,
												fontSize: 10,
												fontWeight: FontWeight.w500,
											),
										),
									],
								),
							),
						);
					}).toList(),
		);
	}

	Widget _buildSpecialOfferCard() {
		return Container(
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				gradient: const LinearGradient(colors: [lightPurple, primaryPurple]),
				borderRadius: BorderRadius.circular(20),
			),
			child: Row(
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Container(
									padding: const EdgeInsets.symmetric(
										horizontal: 8,
										vertical: 3,
									),
									decoration: BoxDecoration(
										color: accentYellow,
										borderRadius: BorderRadius.circular(6),
									),
									child: const Text(
										'LIMITED OFFER',
										style: TextStyle(
											color: darkBg,
											fontSize: 9,
											fontWeight: FontWeight.bold,
										),
									),
								),
								const SizedBox(height: 10),
								const Text(
									'Get 20% Off\nFirst Session',
									style: TextStyle(
										color: Colors.white,
										fontSize: 20,
										fontWeight: FontWeight.bold,
										height: 1.2,
									),
								),
								const SizedBox(height: 12),
								ElevatedButton(
									onPressed: () {},
									style: ElevatedButton.styleFrom(
										backgroundColor: Colors.white,
										foregroundColor: primaryPurple,
										padding: const EdgeInsets.symmetric(
											horizontal: 18,
											vertical: 8,
										),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(10),
										),
									),
									child: const Text(
										'Book Now',
										style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
									),
								),
							],
						),
					),
					Container(
						width: 80,
						height: 80,
						decoration: BoxDecoration(
							color: Colors.white.withOpacity(0.2),
							borderRadius: BorderRadius.circular(16),
						),
						child: const Icon(Icons.local_offer, color: Colors.white, size: 40),
					),
				],
			),
		);
	}
}
