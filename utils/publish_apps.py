from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def app_manager(client, filepath, unpublish):

    try:
        with open(filepath, 'r') as f:
            app_json = json.load(f)
    except:
        raise

    # do this to scrub private app slugs from public app
    old_id = app_json['id']
    app_json['id'] = old_id[7:]
    app_json['jobAttributes']['execSystemId'] = 'ls6'
    app_json['jobAttributes']['archiveSystemId'] = 'ls6'

    print('  private appId = {}'.format(old_id))
    print('  public appId = {}'.format(app_json['id']))
    print('  appVer = {}'.format(app_json['version']))
    print('  execSystemId = {}'.format(app_json['jobAttributes']['execSystemId']))
    print('  archiveSystemId = {}'.format(app_json['jobAttributes']['archiveSystemId']))
    print('  label = {}'.format(app_json['notes']['label']))

    if unpublish:
        try:
            print('  unpublishing {}...'.format(app_json['id']))
            client.apps.unShareAppPublic(appId=app_json['id'])
        except BaseTapyException as e:
            if 'APPLIB_NOT_FOUND' in e.message:
                print('  ERROR: appId not recognized: {}'.format(app_json['id']))
            else:
                raise
    else:
        try:
            print('  deploying public version of {} as {}'.format(old_id, app_json['id']))
            client.apps.createAppVersion(**app_json)
        except BaseTapyException as e:
            if 'APPAPI_APP_EXISTS' in e.message:
                client.apps.putApp(appId=app_json['id'], appVersion=app_json['version'], **app_json)
                print('  app updated: {}-{}'.format(app_json['id'], app_json['version']))
            else:
                raise

        try:
            print('  publishing {}...'.format(app_json['id']))
            client.apps.shareAppPublic(appId=app_json['id'])
        except BaseTapyException as e:
            if 'APPLIB_NOT_FOUND' in e.message:
                print('  ERROR: appId not recognized: {}'.format(app_json['id']))
            else:
                raise


def main():
    parser = argparse.ArgumentParser(description='Publish an app to all users on the tenant (admin only)')
    parser.add_argument('-u', '--unpublish', action='store_true', help='use this flag to unpublish')
    parser.add_argument('filepath', help='app.json file for app to share publicly')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    app_manager(t, args.filepath, args.unpublish)


if __name__ == "__main__":
    main()


