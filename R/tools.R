# Transform a path for passing to the build system on the command line.
# Leave paths alone for posix. For Windows, mirror the behavior of the
# R package build system by starting with the fully resolved absolute path,
# transforming it to a short path name if it contains spaces, and then
# converting backslashes to forward slashes
asBuildPath <- function(path) {

    if (.Platform$OS.type == "windows") {
        path <- normalizePath(path)
        if (grepl(' ', path, fixed=TRUE))
            path <- utils::shortPathName(path)
        path <- gsub("\\\\", "/", path)
    }

    return(path)
}

.buildClinkCppFlags <- function(linkingToPackages) {
    pkgCxxFlags <- NULL
    for (package in linkingToPackages) {
        packagePath <- find.package(package, NULL, quiet=TRUE)
        packagePath <- asBuildPath(packagePath)
        pkgCxxFlags <- paste(pkgCxxFlags,
            paste0('-I"', packagePath, '/include"'),
            collapse=" ")
    }
    return (pkgCxxFlags)
}

is.mac <- function() {
  Sys.info()["sysname"] == "Darwin"
}

is.snowleopard.R <- function() {
  is.mac() && identical(R.version$os, "darwin10.8.0")
}

is.mavericks.system <- function() {
  is.mac() && identical(system("uname -r", intern = TRUE), "13.2.0")
}
