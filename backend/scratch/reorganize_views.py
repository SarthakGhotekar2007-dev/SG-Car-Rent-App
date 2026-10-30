import os
import shutil
import re

view_dir = r"c:\flutter practice\sg car rent app\frontend\lib\view"
auth_dir = os.path.join(view_dir, "auth")
admin_dir = os.path.join(view_dir, "admin")
user_dir = os.path.join(view_dir, "user")

os.makedirs(auth_dir, exist_ok=True)
os.makedirs(admin_dir, exist_ok=True)
os.makedirs(user_dir, exist_ok=True)

auth_files = [
    'splash_screen.dart',
    'onboarding_screen.dart',
    'login_screen.dart',
    'register_screen.dart',
    'forgot_password_screen.dart'
]

admin_files = [
    'admin_dashboard.dart',
    'admin_profile_screen.dart',
    'manage_cars_screen.dart',
    'add_car_screen.dart',
    'edit_car_screen.dart',
    'manage_bookings_screen.dart'
]

user_files = [
    'home_screen.dart',
    'explore_cars_screen.dart',
    'car_details_screen.dart',
    'booking_date_screen.dart',
    'booking_confirmation_screen.dart',
    'booking_details_screen.dart',
    'my_bookings_screen.dart',
    'favorites_screen.dart',
    'profile_screen.dart',
    'edit_profile_screen.dart',
    'notifications_screen.dart'
]

def get_target_subfolder(filename):
    if filename in auth_files:
        return 'auth'
    elif filename in admin_files:
        return 'admin'
    elif filename in user_files:
        return 'user'
    return None

all_screen_files = set(auth_files + admin_files + user_files)

# Move files to their respective subfolders
for filename in auth_files:
    src = os.path.join(view_dir, filename)
    dst = os.path.join(auth_dir, filename)
    if os.path.exists(src):
        shutil.move(src, dst)

for filename in admin_files:
    src = os.path.join(view_dir, filename)
    dst = os.path.join(admin_dir, filename)
    if os.path.exists(src):
        shutil.move(src, dst)

for filename in user_files:
    src = os.path.join(view_dir, filename)
    dst = os.path.join(user_dir, filename)
    if os.path.exists(src):
        shutil.move(src, dst)

print("Moved all 22 screen files to auth/, admin/, and user/ directories.")

# Now update imports in each file
folders = [('auth', auth_dir, auth_files), ('admin', admin_dir, admin_files), ('user', user_dir, user_files)]

for current_folder_name, current_dir, file_list in folders:
    for filename in file_list:
        filepath = os.path.join(current_dir, filename)
        if not os.path.exists(filepath):
            continue

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Update root imports (e.g. ../const/ -> ../../const/)
        # Because we went one folder deeper
        for root_dir in ['const', 'model', 'repo', 'widgets']:
            content = re.sub(
                rf"import\s+['\"]\.\./{root_dir}/",
                f"import '../../{root_dir}/",
                content
            )

        # Update sibling screen imports
        # For each screen file:
        for target_screen in all_screen_files:
            target_sub = get_target_subfolder(target_screen)
            if not target_sub:
                continue

            if target_sub == current_folder_name:
                # Same folder: keep import 'xxx.dart';
                pass
            else:
                # Different folder: replace import 'xxx.dart' with import '../target_sub/xxx.dart'
                pattern = rf"import\s+['\"]{re.escape(target_screen)}['\"];"
                replacement = f"import '../{target_sub}/{target_screen}';"
                content = re.sub(pattern, replacement, content)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

print("Updated all imports inside view/auth/, view/admin/, and view/user/.")

# Update main.dart
main_dart = r"c:\flutter practice\sg car rent app\frontend\lib\main.dart"
if os.path.exists(main_dart):
    with open(main_dart, 'r', encoding='utf-8') as f:
        m_content = f.read()
    m_content = m_content.replace("import 'view/splash_screen.dart';", "import 'view/auth/splash_screen.dart';")
    with open(main_dart, 'w', encoding='utf-8') as f:
        f.write(m_content)
    print("Updated main.dart import for splash_screen.dart.")
