module git.c.status;

/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */

/**
 * @file git2/status.h
 * @brief Git file status routines
 * @defgroup git_status Git file status routines
 * @ingroup Git
 * @{
 */

import git.c.common;
import git.c.diff;
import git.c.strarray;
import git.c.util;
import git.c.types;

extern (C):

/**
 * Status flags for a single file.
 *
 * A combination of these values will be returned to indicate the status of
 * a file.  Status compares the working directory, the index, and the
 * current HEAD of the repository.  The `GIT_STATUS_INDEX` set of flags
 * represents the status of file in the index relative to the HEAD, and the
 * `GIT_STATUS_WT` set of flags represent the status of the file in the
 * working directory relative to the index.
 */
enum git_status_t {
	GIT_STATUS_CURRENT = 0,

	GIT_STATUS_INDEX_NEW        = (1u << 0),
	GIT_STATUS_INDEX_MODIFIED   = (1u << 1),
	GIT_STATUS_INDEX_DELETED    = (1u << 2),
	GIT_STATUS_INDEX_RENAMED    = (1u << 3),
	GIT_STATUS_INDEX_TYPECHANGE = (1u << 4),

	GIT_STATUS_WT_NEW           = (1u << 7),
	GIT_STATUS_WT_MODIFIED      = (1u << 8),
	GIT_STATUS_WT_DELETED       = (1u << 9),
	GIT_STATUS_WT_TYPECHANGE    = (1u << 10),
	GIT_STATUS_WT_RENAMED       = (1u << 11),

	GIT_STATUS_IGNORED          = (1u << 14),
} ;

mixin _ExportEnumMembers!git_status_t;

/**
 * Function pointer to receive status on individual files
 *
 * `path` is the relative path to the file from the root of the repository.
 *
 * `status_flags` is a combination of `git_status_t` values that apply.
 *
 * `payload` is the value you passed to the foreach function as payload.
 */
alias git_status_cb = int function(
	const(char)* path, uint status_flags, void *payload);

/**
 * For extended status, select the files on which to report status.
 *
 * - GIT_STATUS_SHOW_INDEX_AND_WORKDIR is the default.  This roughly
 *   matches `git status --porcelain` where each file gets a callback
 *   indicating its status in the index and in the working directory.
 * - GIT_STATUS_SHOW_INDEX_ONLY only gives status based on HEAD to index
 *   comparison, not looking at working directory changes.
 * - GIT_STATUS_SHOW_WORKDIR_ONLY only gives status based on index to
 *   working directory comparison, not comparing the index to the HEAD.
 * - GIT_STATUS_SHOW_INDEX_THEN_WORKDIR runs index-only then workdir-only,
 *   issuing (up to) two callbacks per file (first index, then workdir).
 *   This is slightly more efficient than separate calls and can make it
 *   easier to emulate plain `git status` text output.
 */
enum git_status_show_t {
	GIT_STATUS_SHOW_INDEX_AND_WORKDIR = 0,
	GIT_STATUS_SHOW_INDEX_ONLY = 1,
	GIT_STATUS_SHOW_WORKDIR_ONLY = 2,
	GIT_STATUS_SHOW_INDEX_THEN_WORKDIR = 3,
} ;

mixin _ExportEnumMembers!git_status_show_t;

/**
 * Flags to control status callbacks
 *
 * - GIT_STATUS_OPT_INCLUDE_UNTRACKED says that callbacks should be made
 *   on untracked files.  These will only be made if the workdir files are
 *   included in the status "show" option.
 * - GIT_STATUS_OPT_INCLUDE_IGNORED says that ignored files get callbacks.
 *   Again, these callbacks will only be made if the workdir files are
 *   included in the status "show" option.
 * - GIT_STATUS_OPT_INCLUDE_UNMODIFIED indicates that callback should be
 *   made even on unmodified files.
 * - GIT_STATUS_OPT_EXCLUDE_SUBMODULES indicates that submodules should be
 *   skipped.  This only applies if there are no pending typechanges to
 *   the submodule (either from or to another type).
 * - GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS indicates that all files in
 *   untracked directories should be included.  Normally if an entire
 *   directory is new, then just the top-level directory is included (with
 *   a trailing slash on the entry name).  This flag says to include all
 *   of the individual files in the directory instead.
 * - GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH indicates that the given path
 *   should be treated as a literal path, and not as a pathspec pattern.
 * - GIT_STATUS_OPT_RECURSE_IGNORED_DIRS indicates that the contents of
 *   ignored directories should be included in the status.  This is like
 *   doing `git ls-files -o -i --exclude-standard` with core git.
 * - GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX indicates that rename detection
 *   should be processed between the head and the index and enables
 *   the GIT_STATUS_INDEX_RENAMED as a possible status flag.
 * - GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR indicates tha rename
 *   detection should be run between the index and the working directory
 *   and enabled GIT_STATUS_WT_RENAMED as a possible status flag.
 * - GIT_STATUS_OPT_SORT_CASE_SENSITIVELY overrides the native case
 *   sensitivity for the file system and forces the output to be in
 *   case-sensitive order
 * - GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY overrides the native case
 *   sensitivity for the file system and forces the output to be in
 *   case-insensitive order
 *
 * Calling `git_status_foreach()` is like calling the extended version
 * with: GIT_STATUS_OPT_INCLUDE_IGNORED, GIT_STATUS_OPT_INCLUDE_UNTRACKED,
 * and GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS.  Those options are bundled
 * together as `GIT_STATUS_OPT_DEFAULTS` if you want them as a baseline.
 */
enum git_status_opt_t {
	GIT_STATUS_OPT_INCLUDE_UNTRACKED        = (1u << 0),
	GIT_STATUS_OPT_INCLUDE_IGNORED          = (1u << 1),
	GIT_STATUS_OPT_INCLUDE_UNMODIFIED       = (1u << 2),
	GIT_STATUS_OPT_EXCLUDE_SUBMODULES       = (1u << 3),
	GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS   = (1u << 4),
	GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH   = (1u << 5),
	GIT_STATUS_OPT_RECURSE_IGNORED_DIRS     = (1u << 6),
	GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX    = (1u << 7),
	GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR = (1u << 8),
	GIT_STATUS_OPT_SORT_CASE_SENSITIVELY    = (1u << 9),
	GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY  = (1u << 10),
} ;

mixin _ExportEnumMembers!git_status_opt_t;

enum GIT_STATUS_OPT_DEFAULTS =
	(git_status_opt_t.GIT_STATUS_OPT_INCLUDE_IGNORED |
	git_status_opt_t.GIT_STATUS_OPT_INCLUDE_UNTRACKED |
	git_status_opt_t.GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS);

/**
 * Options to control how `git_status_foreach_ext()` will issue callbacks.
 *
 * This structure is set so that zeroing it out will give you relatively
 * sane defaults.
 *
 * The `show` value is one of the `git_status_show_t` constants that
 * control which files to scan and in what order.
 *
 * The `flags` value is an OR'ed combination of the `git_status_opt_t`
 * values above.
 *
 * The `pathspec` is an array of path patterns to match (using
 * fnmatch-style matching), or just an array of paths to match exactly if
 * `GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH` is specified in the flags.
 */
struct git_status_options {
	uint      version_;
	git_status_show_t show;
	uint      flags;
	git_strarray      pathspec;
} ;

enum GIT_STATUS_OPTIONS_VERSION = 1;
enum git_status_options GIT_STATUS_OPTIONS_INIT = { GIT_STATUS_OPTIONS_VERSION };


/**
 * A status entry, providing the differences between the file as it exists
 * in HEAD and the index, and providing the differences between the index
 * and the working directory.
 *
 * The `status` value provides the status flags for this file.
 *
 * The `head_to_index` value provides detailed information about the
 * differences between the file in HEAD and the file in the index.
 *
 * The `index_to_workdir` value provides detailed information about the
 * differences between the file in the index and the file in the
 * working directory.
 */
struct git_status_entry {
	git_status_t status;
	git_diff_delta *head_to_index;
	git_diff_delta *index_to_workdir;
} ;


/**
 * Gather file statuses and run a callback for each one.
 *
 * The callback is passed the path of the file, the status (a combination of
 * the `git_status_t` values above) and the `payload` data pointer passed
 * into this function.
 *
 * If the callback returns a non-zero value, this function will stop looping
 * and return GIT_EUSER.
 *
 * @param repo A repository object
 * @param callback The function to call on each file
 * @param payload Pointer to pass through to callback function
 * @return 0 on success, GIT_EUSER on non-zero callback, or error code
 */
int git_status_foreach(
	git_repository *repo,
	git_status_cb callback,
	void *payload);

/**
 * Gather file status information and run callbacks as requested.
 *
 * This is an extended version of the `git_status_foreach()` API that
 * allows for more granular control over which paths will be processed and
 * in what order.  See the `git_status_options` structure for details
 * about the additional controls that this makes available.
 *
 * @param repo Repository object
 * @param opts Status options structure
 * @param callback The function to call on each file
 * @param payload Pointer to pass through to callback function
 * @return 0 on success, GIT_EUSER on non-zero callback, or error code
 */
int git_status_foreach_ext(
	git_repository *repo,
	const(git_status_options)* opts,
	git_status_cb callback,
	void *payload);

/**
 * Get file status for a single file.
 *
 * This is not quite the same as calling `git_status_foreach_ext()` with
 * the pathspec set to the specified path.
 *
 * @param status_flags The status value for the file
 * @param repo A repository object
 * @param path The file to retrieve status for, rooted at the repo's workdir
 * @return 0 on success, GIT_ENOTFOUND if the file is not found in the HEAD,
 *      index, and work tree, GIT_EINVALIDPATH if `path` points at a folder,
 *      GIT_EAMBIGUOUS if "path" matches multiple files, -1 on other error.
 */
int git_status_file(
	uint *status_flags,
	git_repository *repo,
	const(char)* path);

/**
 * Gather file status information and populate the `git_status_list`.
 *
 * @param out Pointer to store the status results in
 * @param repo Repository object
 * @param opts Status options structure
 * @return 0 on success or error code
 */
int git_status_list_new(
	git_status_list **out_,
	git_repository *repo,
	const(git_status_options)* opts);

/**
 * Gets the count of status entries in this list.
 *
 * @param statuslist Existing status list object
 * @return the number of status entries
 */
size_t git_status_list_entrycount(
	git_status_list *statuslist);

/**
 * Get a pointer to one of the entries in the status list.
 *
 * The entry is not modifiable and should not be freed.
 *
 * @param statuslist Existing status list object
 * @param idx Position of the entry
 * @return Pointer to the entry; NULL if out of bounds
 */
const(git_status_entry)*  git_status_byindex(
	git_status_list *statuslist,
	size_t idx);

/**
 * Free an existing status list
 *
 * @param statuslist Existing status list object
 */
void git_status_list_free(
	git_status_list *statuslist);

/**
 * Test if the ignore rules apply to a given file.
 *
 * This function checks the ignore rules to see if they would apply to the
 * given file.  This indicates if the file would be ignored regardless of
 * whether the file is already in the index or committed to the repository.
 *
 * One way to think of this is if you were to do "git add ." on the
 * directory containing the file, would it be added or not?
 *
 * @param ignored Boolean returning 0 if the file is not ignored, 1 if it is
 * @param repo A repository object
 * @param path The file to check ignores for, rooted at the repo's workdir.
 * @return 0 if ignore rules could be processed for the file (regardless
 *         of whether it exists or not), or an error < 0 if they could not.
 */
int git_status_should_ignore(
	int *ignored,
	git_repository *repo,
	const(char)* path);
