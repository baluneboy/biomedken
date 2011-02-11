using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace ClassLibraryFileGlobber
{
    // this class name never really gets used, sorta just a placeholder to cover Extension Methods
    public static class FileSystemInfoExtender
    {

        // Extension method for FileSystemInfo to get type (file or directory)
        public static string GetMyType(this FileSystemInfo fsi)
        {
            //  Assume that this entry is a file.
            string str = "File";

            // Determine if entry is really a directory
            if ((fsi.Attributes & FileAttributes.Directory) == FileAttributes.Directory)
            {
                str = "Directory";
            }
            return str;
        }

        #region UNTESTED 3RD PARTY CODE
        // Iterate all files in a path, with 
        // an option to recurse through subdirectories
        public static IEnumerable<FileSystemInfo> IterateFiles(
            this FileSystemInfo targ, bool recurse)
        {
            if (targ == null)
                throw new ArgumentNullException("targ");

            if (recurse)
            {
                DirectoryInfo diTarg = targ as DirectoryInfo;
                // If targ is a directory
                if (diTarg != null)
                {
                    // Get its contents as FileSystemInfo objects
                    FileSystemInfo[] fsis = diTarg.GetFileSystemInfos();
                    foreach (FileSystemInfo fsi in fsis)
                    {
                        foreach (FileSystemInfo fsiInner in fsi.IterateFiles(recurse))
                            yield return fsiInner;
                    }
                }
            }
            // return initial target
            yield return targ;
        }


        // Iterate all directories in a path, with
        // an option to recurse through subdirectories
        public static IEnumerable<FileSystemInfo> IterateDirectories(
            this DirectoryInfo diTarg, bool recurse)
        {
            if (diTarg == null)
                throw new ArgumentNullException("diTarg");

            if (recurse) // return its children
            {
                DirectoryInfo[] dirs = diTarg.GetDirectories();
                foreach (DirectoryInfo dir in dirs)
                {
                    foreach (DirectoryInfo dirInner in dir.IterateDirectories(recurse))
                    {
                        yield return dirInner;
                    }
                }
            }
            yield return diTarg; // return the current dir
        }
    }
    #region FileAttributesExtender

    public static class FileAttributesExtender
    {
        // Return lhs flags plus rhs flags
        public static FileAttributes Union(
            this FileAttributes lhs, FileAttributes rhs)
        {
            return lhs | rhs;
        }

        // Return flags common to lhs and rhs
        public static FileAttributes Intersection(
             this FileAttributes lhs, FileAttributes rhs)
        {
            return lhs & rhs;
        }

        // Return lhs flags minus rhs flags
        public static FileAttributes Difference(
             this FileAttributes lhs, FileAttributes rhs)
        {
            FileAttributes common = lhs & rhs;
            int res = (int)lhs - (int)common;
            return (FileAttributes)(res);
        }

        // Return true if lhs contains all the flags within rhs
        public static bool Contains(
             this FileAttributes lhs, FileAttributes rhs)
        {
            FileAttributes common = lhs & rhs;
            return (common == rhs);
        }

        // Return true if lhs contains one of the flags within rhs
        public static bool ContainsAnyOf(
            this FileAttributes lhs, FileAttributes rhs)
        {
            FileAttributes common = lhs & rhs;
            return ((int)common > 0);
        }

        // NON-extension methods here
        public static FileAttributes FromString(string source)
        {
            FileAttributes res = (FileAttributes)Enum.Parse(
                 typeof(FileAttributes), source, true);
            return res;
        }

    }

    #endregion FileAttributesExtender
#endregion
}