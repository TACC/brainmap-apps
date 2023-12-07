from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def app_manager(client, filepath):

    try:
        with open(filepath, 'r') as f:
            app_json = json.load(f)
    except:
        raise

    print('  appId = {}'.format(app_json['id']))
    print('  appVer = {}'.format(app_json['version']))

    try:
        client.apps.createAppVersion(**app_json)
        print('  app created: {}-{}'.format(app_json['id'], app_json['version']))
    except BaseTapyException as e:
        if 'APPAPI_APP_EXISTS' in e.message:
            client.apps.putApp(appId=app_json['id'], appVersion=app_json['version'], **app_json)
            print('  app updated: {}-{}'.format(app_json['id'], app_json['version']))
        else:
            raise


def main():
    parser = argparse.ArgumentParser(description='Add a new app or update an existing app')
    parser.add_argument('filepath', help='app.json file for app to be added or updated')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    app_manager(t, args.filepath)


if __name__ == "__main__":
    main()
