from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def job_submit(client, filepath):

    try:
        with open(filepath, 'r') as f:
            job_json = json.load(f)
    except:
        raise

    print('  jobName = {}'.format(job_json['name']))
    print('  app = {}-{}'.format(job_json['appId'], job_json['appVersion']))

    try:
        response = client.jobs.submitJob(**job_json)
        print('  job submitted: {}'.format(response.uuid))
        #response2 = client.jobs.getJobStatus(jobUuid=response.uuid)
        #print(response2)
    except BaseTapyException as e:
        raise


def main():
    parser = argparse.ArgumentParser(description='Run a job')
    parser.add_argument('filepath', help='job.json file containing job details')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True)
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    job_submit(t, args.filepath)


if __name__ == "__main__":
    main()
