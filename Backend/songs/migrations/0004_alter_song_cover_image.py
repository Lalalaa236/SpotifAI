
 
from django.db import migrations, models
 
class Migration(migrations.Migration):
 
    dependencies = [
        ('songs', '0003_alter_song_audio_file_alter_song_genres'),
    ]
 
    operations = [
        migrations.AlterField(
            model_name='song',
            name='cover_image',
            field=models.URLField(blank=True, null=True),
        ),
    ]