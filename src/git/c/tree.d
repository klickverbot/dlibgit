module git.c.tree;

/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */

/**
 * @file git2/tree.h
 * @brief Git tree parsing, loading routines
 * @defgroup git_tree Git tree parsing, loading routines
 * @ingroup Git
 * @{
 */

import git.c.common;
import git.c.object_;
import git.c.oid;
import git.c.util;
import git.c.types;

extern (C):

/**
 * Lookup a tree object from the repository.
 *
 * @param out Pointer to the looked up tree
 * @param repo The repo to use when locating the tree.
 * @param id Identity of the tree to locate.
 * @return 0 or an error code
 */
int git_tree_lookup(
	git_tree **out_, git_repository *repo, const(git_oid)* id);

/**
 * Lookup a tree object from the repository,
 * given a prefix of its identifier (short id).
 *
 * @see git_object_lookup_prefix
 *
 * @param out pointer to the looked up tree
 * @param repo the repo to use when locating the tree.
 * @param id identity of the tree to locate.
 * @param len the length of the short identifier
 * @return 0 or an error code
 */
int git_tree_lookup_prefix(
	git_tree **out_,
	git_repository *repo,
	const(git_oid)* id,
	size_t len);

/**
 * Close an open tree
 *
 * You can no longer use the git_tree pointer after this call.
 *
 * IMPORTANT: You MUST call this method when you stop using a tree to
 * release memory. Failure to do so will cause a memory leak.
 *
 * @param tree The tree to close
 */
void git_tree_free(git_tree *tree);

/**
 * Get the id of a tree.
 *
 * @param tree a previously loaded tree.
 * @return object identity for the tree.
 */
const(git_oid)*  git_tree_id(const(git_tree)* tree);

/**
 * Get the repository that contains the tree.
 *
 * @param tree A previously loaded tree.
 * @return Repository that contains this tree.
 */
git_repository * git_tree_owner(const(git_tree)* tree);

/**
 * Get the number of entries listed in a tree
 *
 * @param tree a previously loaded tree.
 * @return the number of entries in the tree
 */
size_t git_tree_entrycount(const(git_tree)* tree);

/**
 * Lookup a tree entry by its filename
 *
 * This returns a git_tree_entry that is owned by the git_tree.  You don't
 * have to free it, but you must not use it after the git_tree is released.
 *
 * @param tree a previously loaded tree.
 * @param filename the filename of the desired entry
 * @return the tree entry; NULL if not found
 */
const(git_tree_entry)*  git_tree_entry_byname(
	const(git_tree)* tree, const(char)* filename);

/**
 * Lookup a tree entry by its position in the tree
 *
 * This returns a git_tree_entry that is owned by the git_tree.  You don't
 * have to free it, but you must not use it after the git_tree is released.
 *
 * @param tree a previously loaded tree.
 * @param idx the position in the entry list
 * @return the tree entry; NULL if not found
 */
const(git_tree_entry)*  git_tree_entry_byindex(
	const(git_tree)* tree, size_t idx);

/**
 * Lookup a tree entry by SHA value.
 *
 * This returns a git_tree_entry that is owned by the git_tree.  You don't
 * have to free it, but you must not use it after the git_tree is released.
 *
 * Warning: this must examine every entry in the tree, so it is not fast.
 *
 * @param tree a previously loaded tree.
 * @param oid the sha being looked for
 * @return the tree entry; NULL if not found
 */
const(git_tree_entry)*  git_tree_entry_byoid(
	const(git_tree)* tree, const(git_oid)* oid);

/**
 * Retrieve a tree entry contained in a tree or in any of its subtrees,
 * given its relative path.
 *
 * Unlike the other lookup functions, the returned tree entry is owned by
 * the user and must be freed explicitly with `git_tree_entry_free()`.
 *
 * @param out Pointer where to store the tree entry
 * @param root Previously loaded tree which is the root of the relative path
 * @param path Path to the contained entry
 * @return 0 on success; GIT_ENOTFOUND if the path does not exist
 */
int git_tree_entry_bypath(
	git_tree_entry **out_,
	const(git_tree)* root,
	const(char)* path);

/**
 * Duplicate a tree entry
 *
 * Create a copy of a tree entry. The returned copy is owned by the user,
 * and must be freed explicitly with `git_tree_entry_free()`.
 *
 * @param entry A tree entry to duplicate
 * @return a copy of the original entry or NULL on error (alloc failure)
 */
git_tree_entry * git_tree_entry_dup(const(git_tree_entry)* entry);

/**
 * Free a user-owned tree entry
 *
 * IMPORTANT: This function is only needed for tree entries owned by the
 * user, such as the ones returned by `git_tree_entry_dup()` or
 * `git_tree_entry_bypath()`.
 *
 * @param entry The entry to free
 */
void git_tree_entry_free(git_tree_entry *entry);

/**
 * Get the filename of a tree entry
 *
 * @param entry a tree entry
 * @return the name of the file
 */
const(char)*  git_tree_entry_name(const(git_tree_entry)* entry);

/**
 * Get the id of the object pointed by the entry
 *
 * @param entry a tree entry
 * @return the oid of the object
 */
const(git_oid)*  git_tree_entry_id(const(git_tree_entry)* entry);

/**
 * Get the type of the object pointed by the entry
 *
 * @param entry a tree entry
 * @return the type of the pointed object
 */
git_otype git_tree_entry_type(const(git_tree_entry)* entry);

/**
 * Get the UNIX file attributes of a tree entry
 *
 * @param entry a tree entry
 * @return filemode as an integer
 */
git_filemode_t git_tree_entry_filemode(const(git_tree_entry)* entry);

/**
 * Compare two tree entries
 *
 * @param e1 first tree entry
 * @param e2 second tree entry
 * @return <0 if e1 is before e2, 0 if e1 == e2, >0 if e1 is after e2
 */
int git_tree_entry_cmp(const(git_tree_entry)* e1, const(git_tree_entry)* e2);

/**
 * Convert a tree entry to the git_object it points too.
 *
 * You must call `git_object_free()` on the object when you are done with it.
 *
 * @param object_out pointer to the converted object
 * @param repo repository where to lookup the pointed object
 * @param entry a tree entry
 * @return 0 or an error code
 */
int git_tree_entry_to_object(
	git_object **object_out,
	git_repository *repo,
	const(git_tree_entry)* entry);

/**
 * Create a new tree builder.
 *
 * The tree builder can be used to create or modify trees in memory and
 * write them as tree objects to the database.
 *
 * If the `source` parameter is not NULL, the tree builder will be
 * initialized with the entries of the given tree.
 *
 * If the `source` parameter is NULL, the tree builder will start with no
 * entries and will have to be filled manually.
 *
 * @param out Pointer where to store the tree builder
 * @param source Source tree to initialize the builder (optional)
 * @return 0 on success; error code otherwise
 */
int git_treebuilder_create(
	git_treebuilder **out_, const(git_tree)* source);

/**
 * Clear all the entires in the builder
 *
 * @param bld Builder to clear
 */
void git_treebuilder_clear(git_treebuilder *bld);

/**
 * Get the number of entries listed in a treebuilder
 *
 * @param bld a previously loaded treebuilder.
 * @return the number of entries in the treebuilder
 */
uint git_treebuilder_entrycount(git_treebuilder *bld);

/**
 * Free a tree builder
 *
 * This will clear all the entries and free to builder.
 * Failing to free the builder after you're done using it
 * will result in a memory leak
 *
 * @param bld Builder to free
 */
void git_treebuilder_free(git_treebuilder *bld);

/**
 * Get an entry from the builder from its filename
 *
 * The returned entry is owned by the builder and should
 * not be freed manually.
 *
 * @param bld Tree builder
 * @param filename Name of the entry
 * @return pointer to the entry; NULL if not found
 */
const(git_tree_entry)*  git_treebuilder_get(
	git_treebuilder *bld, const(char)* filename);

/**
 * Add or update an entry to the builder
 *
 * Insert a new entry for `filename` in the builder with the
 * given attributes.
 *
 * If an entry named `filename` already exists, its attributes
 * will be updated with the given ones.
 *
 * The optional pointer `out` can be used to retrieve a pointer to
 * the newly created/updated entry.  Pass NULL if you do not need it.
 *
 * No attempt is being made to ensure that the provided oid points
 * to an existing git object in the object database, nor that the
 * attributes make sense regarding the type of the pointed at object.
 *
 * @param out Pointer to store the entry (optional)
 * @param bld Tree builder
 * @param filename Filename of the entry
 * @param id SHA1 oid of the entry
 * @param filemode Folder attributes of the entry. This parameter must
 *			be valued with one of the following entries: 0040000, 0100644,
 *			0100755, 0120000 or 0160000.
 * @return 0 or an error code
 */
int git_treebuilder_insert(
	const(git_tree_entry)* *out_,
	git_treebuilder *bld,
	const(char)* filename,
	const(git_oid)* id,
	git_filemode_t filemode);

/**
 * Remove an entry from the builder by its filename
 *
 * @param bld Tree builder
 * @param filename Filename of the entry to remove
 */
int git_treebuilder_remove(
	git_treebuilder *bld, const(char)* filename);

alias git_treebuilder_filter_cb = int function(
	const(git_tree_entry)* entry, void *payload);

/**
 * Filter the entries in the tree
 *
 * The `filter` callback will be called for each entry in the tree with a
 * pointer to the entry and the provided `payload`; if the callback returns
 * non-zero, the entry will be filtered (removed from the builder).
 *
 * @param bld Tree builder
 * @param filter Callback to filter entries
 * @param payload Extra data to pass to filter
 */
void git_treebuilder_filter(
	git_treebuilder *bld,
	git_treebuilder_filter_cb filter,
	void *payload);

/**
 * Write the contents of the tree builder as a tree object
 *
 * The tree builder will be written to the given `repo`, and its
 * identifying SHA1 hash will be stored in the `id` pointer.
 *
 * @param id Pointer to store the OID of the newly written tree
 * @param repo Repository in which to store the object
 * @param bld Tree builder to write
 * @return 0 or an error code
 */
int git_treebuilder_write(
	git_oid *id, git_repository *repo, git_treebuilder *bld);


/** Callback for the tree traversal method */
alias git_treewalk_cb = int function(
	const(char)* root, const(git_tree_entry)* entry, void *payload);

/** Tree traversal modes */
enum git_treewalk_mode {
	GIT_TREEWALK_PRE = 0, /* Pre-order */
	GIT_TREEWALK_POST = 1, /* Post-order */
} ;

mixin _ExportEnumMembers!git_treewalk_mode;

/**
 * Traverse the entries in a tree and its subtrees in post or pre order.
 *
 * The entries will be traversed in the specified order, children subtrees
 * will be automatically loaded as required, and the `callback` will be
 * called once per entry with the current (relative) root for the entry and
 * the entry data itself.
 *
 * If the callback returns a positive value, the passed entry will be
 * skipped on the traversal (in pre mode). A negative value stops the walk.
 *
 * @param tree The tree to walk
 * @param mode Traversal mode (pre or post-order)
 * @param callback Function to call on each tree entry
 * @param payload Opaque pointer to be passed on each callback
 * @return 0 or an error code
 */
int git_tree_walk(
	const(git_tree)* tree,
	git_treewalk_mode mode,
	git_treewalk_cb callback,
	void *payload);
