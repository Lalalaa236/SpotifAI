from django.db import migrations, models
 
 
class Migration(migrations.Migration):
 
    dependencies = [
        ('genres', '0001_initial'),
        ('songs', '0002_remove_song_duration_song_audio_url_song_cover_image_and_more'),
    ]
 
    operations = [
        migrations.AlterField(
            model_name='song',
            name='audio_file',
            field=models.FileField(null=True, upload_to='songs/'),
        ),
        migrations.AlterField(
            model_name='song',
            name='genres',
            field=models.ManyToManyField(related_name='songs', to='genres.genre'),
        ),
    ]