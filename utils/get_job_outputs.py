from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def job_outputs(client, uuid):

    try:
        client.jobs.getJobOutputDownload(jobUuid=uuid, outputPath='./')
    except BaseTapyException as e:
        raise


def main():
    parser = argparse.ArgumentParser(description='Get outputs of a job')
    parser.add_argument('uuid', help='job uuid (received when submitting job)')
    args = parser.parse_args()

    if len(args.uuid) >= 1:
        print(f'Checking {args.uuid}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True)
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    job_outputs(t, args.uuid)


if __name__ == "__main__":
    main()
