module git.c.reset;

/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */

/**
 * @file git2/reset.h
 * @brief Git reset management routines
 * @ingroup Git
 * @{
 */

import git.c.strarray;
import git.c.util;
import git.c.types;

extern (C):

/**
 * Kinds of reset operation
 */
enum git_reset_t {
	GIT_RESET_SOFT  = 1, /** Move the head to the given commit */
	GIT_RESET_MIXED = 2, /** SOFT plus reset index to the commit */
	GIT_RESET_HARD  = 3, /** MIXED plus changes in working tree discarded */
} ;

mixin _ExportEnumMembers!git_reset_t;

/**
 * Sets the current head to the specified commit oid and optionally
 * resets the index and working tree to match.
 *
 * SOFT reset means the Head will be moved to the commit.
 *
 * MIXED reset will trigger a SOFT reset, plus the index will be replaced
 * with the content of the commit tree.
 *
 * HARD reset will trigger a MIXED reset and the working directory will be
 * replaced with the content of the index.  (Untracked and ignored files
 * will be left alone, however.)
 *
 * TODO: Implement remaining kinds of resets.
 *
 * @param repo Repository where to perform the reset operation.
 *
 * @param target Commit oid to which the Head should be moved to. This object
 * must belong to the given `repo` and can either be a git_commit or a
 * git_tag. When a git_tag is being passed, it should be dereferencable
 * to a git_commit which oid will be used as the target of the branch.
 *
 * @param reset_type Kind of reset operation to perform.
 *
 * @return 0 on success or an error code
 */
int git_reset(
	git_repository *repo, git_object *target, git_reset_t reset_type);

/**
 * Updates some entries in the index from the target commit tree.
 *
 * The scope of the updated entries is determined by the paths
 * being passed in the `pathspec` parameters.
 *
 * Passing a NULL `target` will result in removing
 * entries in the index matching the provided pathspecs.
 *
 * @param repo Repository where to perform the reset operation.
 *
 * @param target The commit oid which content will be used to reset the content
 * of the index.
 *
 * @param pathspecs List of pathspecs to operate on.
 *
 * @return 0 on success or an error code < 0
 */
int git_reset_default(
	git_repository *repo,
	git_object *target,
	git_strarray* pathspecs);
