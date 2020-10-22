#!/bin/bash
echo "from django.contrib.auth.models import User; User.objects.create_superuser('adminsuperuser', 'admin@example.com', 'Saxo0855')" | /usr/bin/python3 ~/manage.py shell