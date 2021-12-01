import json
import logging
import os
import azure.functions as func
from io import BytesIO

from azure.identity._credentials import default
from azure.storage.blob import BlobServiceClient    
from azure.identity import DefaultAzureCredential
from PIL import Image

def main(event: func.EventGridEvent, msg: func.Out[str]) -> None:
    result = {
        'id': event.id,
        'data': event.get_json(),
        'topic': event.topic,
        'subject': event.subject,
        'event_type': event.event_type
    }

    logging.info('Python EventGrid trigger processed an event: %s', json.dumps(result))
    logging.info("Event data: %s", result["data"])

    default_credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(os.environ['STORAGE_ACCOUNT_URL'], credential=default_credential)
    
    output_container_client = blob_service_client.get_container_client('results')
    input_container_client = blob_service_client.get_container_client('uploads')
    #blob_client = BlobClient.from_url(event.data.url, credential=default_credential)
    
    filename = os.path.basename(event.subject)
    input_buffer = BytesIO()
    input_container_client.download_blob(filename).readinto(input_buffer)
    input_buffer.seek(0)

    logging.info('Downloaded file: %s', filename)

    new_size = 200,200
    im = Image.open(input_buffer)
    im.thumbnail(new_size)
    
    thumb_filename = 'thumb-' + filename
    output_buffer = BytesIO()
    
    logging.info('Saving thumbnail: %s', thumb_filename)
    im.save(output_buffer, format='JPEG', quality=100)
    output_buffer.seek(0)

    logging.info('Uploading thumbnail: %s', thumb_filename)
    output_container_client.upload_blob(thumb_filename, output_buffer.read(), overwrite=True)
    logging.info('Uploaded thumbnail: %s', thumb_filename)

    body = {
        "file_name": filename,
        "thumb_name": thumb_filename     
    }
    logging.info('Sending message to queue: %s', body)
    msg.set(json.dumps(body))

    logging.info('Finished processing. Uploaded file: %s', thumb_filename)