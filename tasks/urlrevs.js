/*
 * grunt-urlrevs
 * https://github.com/Wu-Wu/grunt-urlrevs
 *
 * Copyright (c) 2013 Anton Gerasimov
 * Licensed under the MIT license.
 */

"use strict";

module.exports = function (grunt) {
    var git = require('./lib/git').Git(grunt),
        replaceContent = require('./lib/replace').replaceContent;

    grunt.registerMultiTask("urlrevs", "Manage revisions in css urls", function () {

        var options = this.options({
            abbrev      : 6,
            branch      : 'HEAD',
            filter      : '\\.(png|jpg|jpeg|gif)',
            path        : 'root/i',
            prefix      : 'root',
            valid       : [ '^\\/' ],
            skip        : [ '^https?:\\/\\/', '^\\/\\/', '^data:image\\/(sv|pn)g', '^%23' ],
            implant     : true,
            upcased     : true,
            autocommit  : true,
            message     : 'Wave a magic wand (by urlrevs)'
        });

        // show options if verbose
        grunt.verbose.writeflags(options);

        grunt.verbose.writeln("Verifying uncommited changes..");

        git.status(options.filter, function (output, code) {
            if (!code) {
                if (output.length) {
                    if (options.autocommit) {
                        git.commit({ message: options.message, path: options.path }, function (message, success) {
                            if (!success) {
                                grunt.fatal(message);
                            }
                            else {
                                grunt.log.ok(message);
                            }
                        });
                    }
                    else {
                        grunt.verbose.writeln("Uncommited changes:\n" + output.join("\n"));
                        grunt.fatal("Commit changes manually or set option 'autocommit: true' please.");
                    }
                }
            }
            else {
                grunt.fatal("Unable to get repository status!");
            }
        });

        var lstree_opts = {
            branch      : options.branch,
            abbrev      : options.abbrev,
            path        : options.path,
            prefix      : options.prefix
        };
        grunt.verbose.writeln("Building images revisions tree..");

        var tree = {};

        git.lsTree(lstree_opts, function (output, code) {
            if (!code) {
                tree = output;
                // console.dir(output);
            }
            else {
                grunt.fatal("Unable to build revisions tree!");
            }
        });

        var files = this.filesSrc;

        var changeUrls = function (filename, next) {
            grunt.log.writeln("Processing " + (filename).cyan + "...");
            var content = grunt.file.read(filename).toString(),
                css;
            try {
                css = replaceContent(content, tree, options);
            } 

            catch (error) {
                grunt.fatal(error.message);
            }

            // save changes
            grunt.file.write(filename, css);
            next();
        };

        if (files.length > 0) {
            grunt.util.async.forEachLimit(files, 30, function (file, next) {
                changeUrls(file, next);
            }.bind(this), this.async());
        }
        else {
            grunt.log.writeln('No files to processing');
        }
    });
};
