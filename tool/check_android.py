#!/usr/bin/env python3
"""Run example smoke on an already running Android device, without native scaffolding in Git."""
import argparse
import pathlib
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--device', required=True, help='Flutter device selector; never committed to evidence')
args = parser.parse_args()
source = pathlib.Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='handcrafted-android-') as folder:
    host = pathlib.Path(folder) / 'host'
    subprocess.run(['flutter', 'create', '--platforms=android', '--org', 'dev.handcrafted',
                    '--project-name', 'handcrafted_android_probe', str(host)], check=True)
    shutil.rmtree(host / 'lib')
    shutil.copytree(source / 'example/lib', host / 'lib')
    shutil.copytree(source / 'example/assets', host / 'assets')
    manifest = (source / 'example/pubspec.yaml').read_text()
    manifest = manifest.replace('name: handcrafted_example', 'name: handcrafted_android_probe')
    manifest = manifest.replace('path: ../', f'path: {source.as_posix()}')
    manifest = manifest.replace('dev_dependencies:\n', 'dev_dependencies:\n  integration_test:\n    sdk: flutter\n')
    (host / 'pubspec.yaml').write_text(manifest)
    (host / 'integration_test').mkdir()
    shutil.copyfile(source / 'tool/android_smoke.dart.template', host / 'integration_test/smoke_test.dart')
    subprocess.run(['flutter', 'pub', 'get'], cwd=host, check=True)
    subprocess.run(['flutter', 'test', 'integration_test/smoke_test.dart', '-d', args.device], cwd=host, check=True)
