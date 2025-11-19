FrePPLe Windows Installer
=========================

Thank you for installing FrePPLe - Advanced Planning and Scheduling!

SYSTEM REQUIREMENTS
-------------------
- Windows 10 or Windows Server 2016 or later (64-bit)
- 4 GB RAM minimum (8 GB recommended)
- 2 GB free disk space
- Administrator privileges for installation

WHAT WILL BE INSTALLED
----------------------
FrePPLe installer includes:
- FrePPLe Core Engine (C++ planning engine)
- FrePPLe Web Application (Django-based UI)
- PostgreSQL Database Server (optional, but recommended)
- Python Runtime and Dependencies
- Windows Services for automatic startup

INSTALLATION NOTES
------------------
1. The installer will ask you to configure:
   - Database name and credentials
   - Web server port (default: 8000)
   - Administrator username and password

2. PostgreSQL will be installed and configured automatically
   - Default port: 5432
   - Configured for local access only
   - UTF-8 encoding

3. Python virtual environment will be created
   - All dependencies installed automatically
   - Located in: [InstallDir]\venv

4. Windows services will be created:
   - PostgreSQL-FrePPLe (database server)
   - FrePPLeService (web application)

5. Firewall exception can be added automatically
   - Allows access to web interface on selected port

AFTER INSTALLATION
------------------
1. Open your web browser and navigate to:
   http://localhost:8000

2. Log in with the administrator credentials you created
   (Default: admin/admin if not changed during installation)

3. IMPORTANT: Change the default admin password immediately!
   Go to: User Menu > My Profile > Change Password

4. Explore the demo data or start entering your own planning data

MANAGING THE SERVICE
--------------------
Start FrePPLe:
- Use Start Menu > FrePPLe > Start FrePPLe
- Or run: net start FrePPLeService

Stop FrePPLe:
- Use Start Menu > FrePPLe > Stop FrePPLe
- Or run: net stop FrePPLeService

View Logs:
- Application logs: [InstallDir]\logs\
- PostgreSQL logs: [InstallDir]\logs\postgresql-*.log

DOCUMENTATION
-------------
Complete documentation is available at:
https://frepple.com/docs/current/

Community support:
https://github.com/frePPLe/frepple/discussions

TROUBLESHOOTING
---------------
If FrePPLe doesn't start:
1. Check that PostgreSQL service is running:
   net start PostgreSQL-FrePPLe

2. Check log files in [InstallDir]\logs\

3. Verify database connection in:
   [InstallDir]\etc\frepple\djangosettings.py

4. Ensure firewall allows access to port 8000

If you encounter port conflicts:
1. Edit [InstallDir]\etc\frepple\djangosettings.py
2. Change the FREPPLE_PORT setting
3. Restart the FrePPLeService

UNINSTALLATION
--------------
Use Windows Settings > Apps > FrePPLe > Uninstall

You will be asked if you want to keep your data:
- Yes: Database and configuration files are preserved
- No: Complete removal including all data

LICENSE
-------
FrePPLe Community Edition is released under the MIT License.
See COPYING file for full license text.

SUPPORT
-------
Enterprise Edition with professional support is available from:
https://frepple.com

For issues and bug reports:
https://github.com/frePPLe/frepple/issues

Enjoy using FrePPLe!
