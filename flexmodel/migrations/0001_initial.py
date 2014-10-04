# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='rooms',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('department', models.CharField(max_length=255, null=True, verbose_name='\u041e\u0442\u0434\u0435\u043b')),
                ('spots', models.IntegerField(null=True, verbose_name='\u0412\u043c\u0435\u0441\u0442\u0438\u043c\u043e\u0441\u0442\u044c')),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='users',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('name', models.CharField(max_length=255, null=True, verbose_name='\u0418\u043c\u044f')),
                ('paycheck', models.IntegerField(null=True, verbose_name='\u0417\u0430\u0440\u043f\u043b\u0430\u0442\u0430')),
                ('date_joined', models.DateTimeField(null=True, verbose_name='\u0414\u0430\u0442\u0430 \u043f\u043e\u0441\u0442\u0443\u043f\u043b\u0435\u043d\u0438\u044f \u043d\u0430 \u0440\u0430\u0431\u043e\u0442\u0443')),
            ],
            options={
            },
            bases=(models.Model,),
        ),
    ]
