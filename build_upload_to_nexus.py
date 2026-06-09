import sys
import os
import glob

sys.path.append(os.path.join(os.environ['NEUROLAB_ROOT'], 'lib'))

import artifact_registry
import logging_utils

DIST_DIR_NAME = './dist'
AR = artifact_registry.ArtifactRegistry(maven_group_id='org.farama.ale')

with open('./version.txt', 'r') as f:
    ALE_PY_VERSION = f.readline().strip()

print(f'{ALE_PY_VERSION=}')

LOG = logging_utils.Logging.get()
LOG.enable('syslog', False)
LOG.enable('stdout', True)

for dir_name in os.listdir(DIST_DIR_NAME):
    full_dir_name = os.path.join(DIST_DIR_NAME, dir_name)
    
    if os.path.isdir(os.path.join(full_dir_name)):
        if wheel_fnames := glob.glob('*.whl', root_dir=full_dir_name):
            assert len(wheel_fnames) == 1
            wheel_fname = os.path.join(full_dir_name, wheel_fnames[0])
            print(f'Uploading {wheel_fname=}, classifier={dir_name}')
            AR.attach_asset('ale_py', ALE_PY_VERSION, wheel_fname, asset_ext='whl', asset_classifier=dir_name, replace=True)
            
