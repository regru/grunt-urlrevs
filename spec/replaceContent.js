exports.replaceContent = function (content, reFilter, tree, options, util, _, reSkip, reValid, fs, grunt) {
    var css = content.replace(/(?:src=|url\()([^,\)]+)/igm, function (match, url) {

        var reDetect = /(src\s*=)/g;
        // trim spaces, quotes
        url = url.replace(/^\s+|\s+$/g, '');
        url = url.replace(/['"]/g, '');

        if (/^(\s+)?$/.test(url)) {
            grunt.fatal("Empty URLs are not supported!");
        }

        if (_.some(reSkip, function (re) { return re.test(url); })) {
            // return AS IS
            return match;
        }

        // is valid url?
        var isValid = _.some(reValid, function (re) { return re.test(url); });
        if (!isValid) {
            grunt.fatal("Invalid URL: " + url);
        }

        // is file an image?
        if (reFilter.test(url)) {
            // trim revision if any
            url = url.replace(/\.(~[0-9A-F]*\.)/ig, '.');   // ..part of pathname

            var fileUrl = url.replace(/(\?|#)(.*)/g, '');     // ..query string parameter or hashes

            // is file exists?
            if (!fs.existsSync(options.prefix + fileUrl)) {
               // grunt.fatal("File for " + fileUrl + " does not exist!");
            }

            var rev = tree[fileUrl];

            if (typeof rev !== 'undefined') {
                // uppercase revision
                if (options.upcased) {
                    rev = rev.toUpperCase();
                }

                // implant revision into filename
                if (options.implant) {
                    rev = '~' + rev;
                    url = url.replace(/(.*)\.(.*)/i, function (match, file, ext) { return [file, rev, ext].join('.'); });
                }
                else {
                    url += '?' + rev;
                }
            }
        }

        return reDetect.test(match) ? util.format("src='%s'", url) : util.format("url('%s'", url);
    });

    return css;
};
