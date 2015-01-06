#! /usr/bin/env python

"""A command line utility for recusively extracting nested tar archives."""

__author__ = "Pushpak Dagade"
__date__   = "$4 July, 2011 3:00:00 PM$"

import os
import sys
import re
import tarfile
import subprocess
import wx
import datetime
from argparse import ArgumentParser
from recipes_fileutils import filter_filenames
from pims.files.utils import most_recent_file_with_suffix
from pims.sams.samslogs_checklist import get_latest_samslist_file, summarize_samslist

major_version = 1
minor_version = 1
error_count = 0

file_extensions = ('tar', 'tgz', 'tbz', 'tb2', 'tar.gz', 'tar.bz2')
# Edit this according to the archive types you want to extract. Keep in
# mind that these should be extractable by the tarfile module.

__all__ = ['ExtractNested', 'WalkTreeAndExtract']

def FileExtension(file_name):
    """Return the file extension of file

    'file' should be a string. It can be either the full path of
    the file or just its name (or any string as long it contains
    the file extension.)

    Example #1:
    input (file) -->  'abc.tar.gz'
    return value -->  'tar.gz'
    
    Example #2:
    input (file) -->  'abc.tar'
    return value -->  'tar'
    
    """
    match = re.compile(r"^.*?[.](?P<ext>tar[.]gz|tar[.]bz2|\w+)$",
      re.VERBOSE|re.IGNORECASE).match(file_name)

    if match:           # if match != None:
        ext = match.group('ext')
        return ext
    else:
        return ''       # there is no file extension to file_name

def AppropriateFolderName(folder_fullpath):
    """Return a folder (path) such that it can be safely created in
    without replacing any existing folder in it.

    Check if the folder folder_fullpath exists. If no, return folder_fullpath
    (without changing, because it can be safely created
    without replacing any already existing folder). If yes, append an
    appropriate number to the folder_fullpath such that this new folder_fullpath
    can be safely created.

    Examples:
    folder_name  = '/a/b/untitled folder'
    return value = '/a/b/untitled folder'   (no such folder already exists.)

    folder_name  = '/a/b/untitled folder'
    return value = '/a/b/untitled folder 1' (the folder '/a/b/untitled folder'
                                            already exists but no folder named
                                            '/a/b/untitled folder 1' exists.)

    folder_name  = '/a/b/untitled folder'
    return value = '/a/b/untitled folder 2' (the folders '/a/b/untitled folder'
                                            and '/a/b/untitled folder 1' both
                                            already exist but no folder
                                            '/a/b/untitled folder 2' exists.)
                                        
    """
    if os.path.exists(folder_fullpath):
        folder_name = os.path.basename(folder_fullpath)
        parent_fullpath = os.path.dirname(folder_fullpath)
        match = re.compile(r'^(?P<name>.*)[ ](?P<num>\d+)$').match(folder_name)
        if match:                           # if match != None:
            name = match.group('name')
            number = match.group('num')
            new_folder_name = '%s %d' %(name, int(number)+1)
            new_folder_fullpath = os.path.join(parent_fullpath, new_folder_name)
            return AppropriateFolderName(new_folder_fullpath)
            # Recursively call itself so that it can be check whether a
            # folder with path new_folder_fullpath already exists or not.
        else:
            new_folder_name = '%s 1' %folder_name
            new_folder_fullpath = os.path.join(parent_fullpath, new_folder_name)
            return AppropriateFolderName(new_folder_fullpath)
            # Recursively call itself so that it can be check whether a
            # folder with path new_folder_fullpath already exists or not.
    else:
        return folder_fullpath

def Extract(tarfile_fullpath, delete_tar_file=True):
    """Extract the tarfile_fullpath to an appropriate* folder of the same
    name as the tar file (without an extension) and return the path
    of this folder.

    If delete_tar_file is True, it will delete the tar file after
    its extraction; if False, it won`t. Default value is True as you
    would normally want to delete the (nested) tar files after
    extraction. Pass a False, if you don`t want to delete the
    tar file (after its extraction) you are passing.

    """
    try:
        print "Extracting '%s'" %tarfile_fullpath,
        tar = tarfile.open(tarfile_fullpath)
        extract_folder_fullpath = AppropriateFolderName(tarfile_fullpath[:\
          -1*len(FileExtension(tarfile_fullpath))-1])
        extract_folder_name = os.path.basename(extract_folder_fullpath)
        print "to '%s'..." %extract_folder_name,
        tar.extractall(extract_folder_fullpath)
        print "Done!"
        tar.close()
        if delete_tar_file: os.remove(tarfile_fullpath)
        return extract_folder_name

    except Exception:
        # Exceptions can occur while opening a damaged tar file.
        print '(Error)\n(%s)' %str(sys.exc_info()[1]).capitalize()
        global error_count
        error_count += 1

def WalkTreeAndExtract(parent_dir):
    """Recursively descend the directory tree rooted at parent_dir
    and extract each tar file on the way down (recursively)."""
    try:
        dir_contents = os.listdir(parent_dir)
    except OSError:
        # Exception can occur if trying to open some folder whose
        # permissions this program does not have.
        print 'Error occured. Could not open folder %s\n%s'\
          %( parent_dir, str(sys.exc_info()[1]).capitalize())
        global error_count
        error_count += 1
        return

    for content in dir_contents:
        content_fullpath = os.path.join(parent_dir, content)
        if os.path.isdir(content_fullpath):
            # If content is a folder, walk down it completely.
            WalkTreeAndExtract(content_fullpath)
        elif os.path.isfile(content_fullpath):
            # If content is a file, check if it is a tar file.
            if FileExtension(content_fullpath) in file_extensions:
                # If yes, extract its contents to a new folder.
                extract_folder_name = Extract(content_fullpath)
                if extract_folder_name:     # if extract_folder_name != None:
                    dir_contents.append(extract_folder_name)
                    # Append the newly extracted folder to dir_contents
                    # so that it can be later searched for more tar files
                    # to extract.
        else:
            # Unknown file type.
            print 'Skipping %s. <Neither file nor folder>' % content_fullpath

def ExtractNested(tarfile_fullpath):
    extract_folder_name = Extract(tarfile_fullpath, False)
    if extract_folder_name:         # if extract_folder_name != None
        extract_folder_fullpath = os.path.join(os.path.dirname(
          tarfile_fullpath), extract_folder_name)
        WalkTreeAndExtract(extract_folder_fullpath)
        # Given tar file is extracted to extract_folder_name. Now descend
        # down its directory structure and extract all other tar files
        # (recursively).

def gunzip_walker(dirpath, pattern):
    """walk dirpath and show regex matches of filenamePattern"""
    fullfile_pattern = os.path.join(dirpath, pattern)
    #print 'filter_filenames matching pattern "%s"\n================================' % fullfile_pattern
    for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        print "gunzip %s" % f
        subprocess.call(['gunzip', f])

def get_path(wildcard):
    app = wx.App(None)
    style = wx.FD_OPEN | wx.FD_FILE_MUST_EXIST
    dialog = wx.FileDialog(None, 'Open', wildcard=wildcard, style=style)
    dialog.SetDirectory('/media')
    #dialog.SetWildcard("TGZ Files *.tgz|*.TGZ")
    if dialog.ShowModal() == wx.ID_OK:
        path = dialog.GetPath()
    else:
        path = None
    dialog.Destroy()
    return path

# convert most recent tgz file, then text prompt to continue with it or not
def get_latest_tgz():
    """get most recent tgz file, then text prompt to continue with it or not"""
    
    # get most recent tgz file along a default dir
    tgz_file = most_recent_file_with_suffix('/misc/yoda/secure/2015_downlink', '.tgz')

    # check if dir exists that we might overwrite
    #if os.path.exists( tgz_dir ):
    #    print "Abort: already have XLSX file %s for\nthe latest stofile = %s" % (xlsxfile, stofile)
    #    return

    # at this point, the dir does not exist, so return full path for tgz_file
    return tgz_file

if __name__ == '__main__':
    
    if len(sys.argv) == 1:
        #wildcard = "TGZ files (*.tgz; *.TGZ)|*.tgz;*.TGZ|All files (*.*)|*.*"
        #tgzFile = get_path(wildcard)
        tgzFile = get_latest_tgz()
        prompt_str = 'Want to recursive untar %s [y/n]:' % tgzFile
        inp = raw_input(prompt_str) or "n"
        if 'y' == inp[0].lower():
            #print 'yes'
            d = tgzFile.replace('.tgz', '')
            if os.path.isdir(d):
                print 'abort so we do not clobber existing dir = %s' % d
                raise SystemExit
            else:
                pass
        elif 'n' == inp[0].lower():
            print 'user input "no" for not to continue'
            raise SystemExit
        else:
            print 'user input unrecognized, so do not to continue'
            raise SystemExit

    elif len(sys.argv) == 2:
        tgzFile = sys.argv[1]
        
    ExtractNested(tgzFile)    
    
    #### Use a parser for parsing command line arguments
    ###parser = ArgumentParser(description='Nested tar archive extractor %d.%d'\
    ###  %(major_version,minor_version))
    ###parser.add_argument('tar_paths', metavar='path', type=str, nargs='+',
    ###  help='Path of the tar file to be extracted.')
    ###extraction_paths = parser.parse_args().tar_paths
    ###
    #### Consider each argument passed as a file path and extract it.
    ###for argument in extraction_paths:
    ###    if os.path.exists(argument):
    ###        #print       # a blank line
    ###        ExtractNested(tgzFile)
    ###    else:
    ###        print 'Not a valid path: %s' %argument
    ###        error_count += 1
    ###if error_count !=0: print '%d error(s) occured.' %error_count
    
    # Now gunzip the gz files
    dirpath = os.path.splitext(tgzFile)[0]
    pattern = '.*\.gz$'
    gunzip_walker(dirpath, pattern)
    print 'done unzipping'

    # Now get latest samslist file and apply revised JK checklist on it
    dirpath = '/misc/yoda/secure/%d_downlink' % datetime.datetime.today().year
    samslist_file = get_latest_samslist_file(dirpath)   
    summary_file = summarize_samslist(samslist_file)
    print 'wrote summary file %s' % summary_file
    
    # Now open FOLDER using sublime
    #if len(sys.argv) == 1:
    #    subprocess.call(['/home/pims/Downloads/SublimeText2/sublime_text', '-a', dirpath])
    
