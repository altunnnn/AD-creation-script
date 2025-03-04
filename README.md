🏢 Active Directory Automation Script

📌 Overview

This PowerShell script automates the creation and management of an Active Directory (AD) structure. It:

✅ Creates Organizational Units (OUs) 🏢✅ Randomly distributes 7,300 computers across OUs 💻✅ Creates user accounts 👤✅ Creates security groups 🔒✅ Assigns users to groups 👥✅ Supports removal of OUs for cleanup ❌

📂 CSV Files Used

ou.csv 📜 – Contains Organizational Unit details

group.csv 📜 – Contains Group details

unique_names.csv 📜 – Contains User details

⚙️ Script Workflow

1️⃣ Create OUs based on ou.csv 🏢2️⃣ Distribute Computers across OUs randomly 💻3️⃣ Create Computer Accounts in AD 🖥️4️⃣ Create User Accounts with default credentials 🔑5️⃣ Create Security Groups and add users 👥6️⃣ Remove OUs (optional cleanup step) 🚮

🛠️ How to Run the Script

1️⃣ Ensure the required Active Directory module is installed:

Import-Module ActiveDirectory

2️⃣ Save your CSV files (ou.csv, group.csv, unique_names.csv) in the same directory as the script.
3️⃣ Run the script with administrator privileges:

.\AD-creation-script.ps1

⚠️ Important Notes

Default password for new users: Salam@123 🔐

The script removes OUs in the cleanup step, so use with caution! ⚠️

Users are added to groups only if they belong to the same OU 📁

✅ Completion Message

At the end, you should see:

✅ AD structure creation completed successfully!

Happy automating! 🎉

