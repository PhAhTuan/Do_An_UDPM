#!/bin/bash
# Rebuild the database cleanly from the complete schema
/Applications/MAMP/Library/bin/mysql80/bin/mysql -u root -proot -P 8889 -h 127.0.0.1 < database/do_an_udpm_database_complete.sql

# Now that the schema is clean, seed FAQ knowledge
/Applications/MAMP/Library/bin/mysql80/bin/mysql -u root -proot -P 8889 -h 127.0.0.1 do_an_udpm < database/faq_knowledge_seed.sql

# Finally insert the users
/Applications/MAMP/Library/bin/mysql80/bin/mysql -u root -proot -P 8889 -h 127.0.0.1 do_an_udpm < fix_users.sql
