<p align="center">
<img src="guru.svg" alt="logo">
</p>

# The GURU Project Repository

<table><tr>
<td width="68%">

**The official repository for new Gentoo packages, maintained collaboratively by Gentoo users.**

This README contains some additional useful information for GURU contributors, such as common mistakes, frequently asked questions and other tips and tricks. 

The [GURU regulations](https://wiki.gentoo.org/wiki/Project:GURU#The_regulations), and the Gentoo [developer manual](https://devmanual.gentoo.org/) take precedence over any information here.

*See [wiki.gentoo.org/wiki/Project:GURU](https://wiki.gentoo.org/wiki/Project:GURU) for more information on the project.*

</td>
<td width="27%" style="border-style:solid; border-radius:10px;">

### Contents

1. [Frequently Asked Questions](#FAQ)
2. [Common Mistakes](#CommMist)
3. [Other Tips and Tricks](#tips)
4. [Useful Links](#links)
5. [Email Addresses](#email)

</td>
</tr></table>

## Frequently Asked Questions <a name="FAQ"></a>

- #### How do I contribute?

See [wiki.gentoo.org/wiki/Project:GURU/Information_for_Contributors](https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Contributors)

- #### What are the rules and regulations?

See [wiki.gentoo.org/wiki/Project:GURU#The_regulations](https://wiki.gentoo.org/wiki/Project:GURU#The_regulations)

- #### What does GURU stand for?

This is very secret, but you might find a clue [here](https://dev.gentoo.org/~mgorny/articles/guru-a-new-model-of-contributing-to-gentoo.html#the-acronym).

- #### [GLEP 63](https://www.gentoo.org/glep/glep-0063.html) says I should use a @gentoo.org email address for signing off, do I need an @gentoo.org email address to contribute to GURU?

No, you do not need an @gentoo.org email address to contribute to GURU, these email addresses are for Gentoo developers only. Instead use whichever email address you want to receive bug mail and other communications on. If you're also a [proxy-maintainer](https://wiki.gentoo.org/wiki/Project:Proxy_Maintainers) please use the same email address.

- #### Can I use RESTRICT="mirror"?

Sure, since GURU packages are not mirrored on the [Gentoo mirrors](https://devmanual.gentoo.org/general-concepts/mirrors/index.html) anyway, it makes no difference. You can use RESTRICT="mirror" to avoid unnecessary fetch attempts. This is not required by GURU nor is it prohibited, just be sure to remove it if you want to move your package to the main Gentoo repository.

- #### I need help, where do I go?

You can reach other GURU contributors on [IRC #gentoo-guru](https://webchat.freenode.net/?channels=gentoo-guru), or by emailing guru-committers@gentoo.org.

- #### I found a bug, what do I do?

You can either contact the GURU contributors using one of the options in the previous point, or you can open a bug on our bug tracker: [bugs.gentoo.org/enter_bug.cgi?product=GURU](https://bugs.gentoo.org/enter_bug.cgi?product=GURU)

- #### I found a bug in a package that I do not maintain, and I know how to fix it, can I fix it myself?

As per [the regulations](https://wiki.gentoo.org/wiki/Project:GURU#The_regulations), yes, you can! Just be sure to maintain respectful and professional behaviour.

- #### Can I commit a package without listing myself as explicit maintainer?

As per [the regulations](https://wiki.gentoo.org/wiki/Project:GURU#The_regulations), yes, you can.

- #### I want to make changes to this document, can I?

Please discuss any changes and additions to this document on our [bug tracker](https://bugs.gentoo.org/enter_bug.cgi?product=GURU) prior to committing them.


## Common Mistakes <a name="CommMist"></a>

- #### Gentoo projects shouldn't be in the metadata files

Please don't put Gentoo projects (e.g. the proxy-maint project) in the metadata.xml files. Gentoo projects and developers are **not** responsible for the packages in GURU, as such they should not be listed in the metadata files.

When moving a package from a Pull Request in the [main Gentoo Repository](https://github.com/gentoo/gentoo) to GURU it is easy to forget to remove the [proxy-maint](https://wiki.gentoo.org/wiki/Project:Proxy_Maintainers) project from the metadata.xml file. The same is true for moving from GURU to a ::gentoo Pull Request, if you forget to add proxy-maint to the metadata file the `gentoo-repo-qa-bot` will complain.

- #### Use repoman for committing

`repoman ci` is strongly preferred over `git commit -S` for committing, because [repoman](https://wiki.gentoo.org/wiki/Repoman) does additional checks and regenerates the manifest before committing. Sometimes committing with repoman is not possible (e.g. when committing eclasses or removing packages), in these cases there is no other possibility but to revert to `git commit -S`. In all other cases it is good practice to use repoman.

In GURU we use ['thin manifests'](https://wiki.gentoo.org/wiki/Repository_format/package/Manifest#Thin_Manifest). Because this is not the default, manifest files should be regenerated when moving a package from another overlay that does not use thin manifests (including your [local overlay](https://wiki.gentoo.org/wiki/Custom_repository) unless it is also configured to use thin manifests).

- #### Quote your variables

String variables should be quoted (e.g. not `$P` or `${P}` but `"${P}"`). `repoman -dx full` will warn you about any unquoted variables you might have forgotten about.

- #### Undesirable/Deprecated dependencies

Sometimes a upstream lists dependencies which are considered deprecated. If possible, packages should **not** depend on these deprecated dependencies. Reasons a dependency might be deprecated is that it is too old, unmaintained, or the features it adds are not useful to Gentoo. You can find an overview of the currently deprecated dependencies and the reason they are deprecated in `$(portageq get_repo_path / gentoo)/profiles/package.deprecated`. `repoman -dx full` will warn you if your package depends on a deprecated dependency.

For Python packages there are some additional (test) dependencies that are considered undesirable or not useful, but are not considered deprecated. You can find an overview of those [here](https://dev.gentoo.org/~mgorny/python-guide/distutils.html#enabling-tests).

- #### Licenses of bundled libraries

Some packages include files that are licensed under a different license then the rest of the package. In this case all the licenses should be specified in the LICENSE variable. This is very often the case for packages written in Rust or Go.

Rust and Go packages automagically collect all dependencies. The licenses of the things that are statically linked in these packages should be checked *manually*.


## Other Tips and Tricks <a name="tips"></a>

- #### Use the cmake eclass instead of the cmake-utils eclass

The [cmake-utils eclass](https://devmanual.gentoo.org/eclass-reference/cmake-utils.eclass/index.html) will be deprecated in favour of the [cmake eclass](https://devmanual.gentoo.org/eclass-reference/cmake.eclass/index.html). To make your ebuilds more future proof, you might want to use the cmake eclass instead. These eclasses are functionally equivalent, so replacing references to `cmake-utils_....` with `cmake_....` should just work.

- #### Use the xdg eclass instead of the xdg-utils eclass

The xdg eclass will automatically export the correct functions to the `src_prepare`, `pkg_preinst`, `pkg_postinst` and `pkg_postrm` phases. This means that *often* (but not always) you can save a few lines by using the [xdg](https://devmanual.gentoo.org/eclass-reference/xdg.eclass/index.html) eclass instead of the [xdg-utils](https://devmanual.gentoo.org/eclass-reference/xdg-utils.eclass/index.html) eclass. Please note that if you are using another eclass that exports to the `src_prepare` phase, the xdg eclass **will** overwrite it if it is inherited after that eclass. To fix this, you can inherit the xdg eclass *before* the other eclass.

- #### Use the latest EAPI whenever possible

Since the packages in GURU are all 'new packages' (not in ::gentoo). It is good practice to use the latest [EAPI](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html) (7 at the moment), this makes your ebuilds more future proof.

- #### `repoman -dx full` and `pkgcheck scan`

Running `repoman -dx full` in the directory your ebuild is in will preform some basic checks on your ebuild. Please try to make `repoman -dx full` as happy as possible before committing.

Pkgcheck does even more checks than repoman. While it is good practice to make repoman as happy as possible, it is not necessary to fix *every* issue that pkgcheck reports. Because pkgcheck is *very* strict. That being said, pkgcheck is a very useful tool to perfect your ebuilds.

- #### Tests and documentation for Python packages.

Many Python packages have tests and documentation. Unlike some other eclasses the [distutils-r1 eclass](https://devmanual.gentoo.org/eclass-reference/distutils-r1.eclass/index.html) does not enable support for these tests automatically. This is because there are multiple test runners available for Python. To enable tests for your Python ebuilds, use the `distutils_enable_tests <test-runner>` function. Similarly, support for documentation building with Sphinx can be added with the `distutils_enable_sphinx <subdir> [--no-autodoc | <plugin-pkgs>...]` function. Please note that these functions already append to IUSE and RESTRICT, so there is no need to specify this manually. 

See the [dev manual](https://devmanual.gentoo.org/eclass-reference/distutils-r1.eclass/index.html) and the [Gentoo Python Guide](https://dev.gentoo.org/~mgorny/python-guide/distutils.html) for more information.

- #### Avoid introducing USE flags for small files and optional runtime dependencies.

Installation of small files, like documentation, completions, man pages, etc, does not have to be toggle-able with an USE flag. Instead, just install these files unconditionally. This avoids unnecessary recompilations when an user forgot to enable a flag that installs a small file.

The same holds for optional runtime dependencies. It is not necessary to introduce a USE flag, that does not alter the compiled binary and just pulls in an extra optional runtime dependency. Instead, you can notify the user of these optional runtime dependencies with the `optfeature` function from the [eutils](https://devmanual.gentoo.org/eclass-reference/eutils.eclass/) eclass. If, for whatever reason, it is still desired to introduce an USE flag for optional runtime dependencies, one can still use the `optfeature` function as well to allow the user to choose to avoid recompiling a package.


## Useful Links <a name="links"></a>

- https://wiki.gentoo.org/wiki/Project:GURU
- https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Contributors
- https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Trusted_Contributors
- https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds
- https://devmanual.gentoo.org/quickstart
- https://devmanual.gentoo.org/ebuild-writing
- https://devmanual.gentoo.org/ebuild-writing/variables
- https://devmanual.gentoo.org/function-reference
- https://devmanual.gentoo.org/function-reference/install-functions


## Email Addresses <a name="email"></a>

- guru@gentoo.org (Reach everyone involved in GURU)
- guru-committers@gentoo.org (Reach all contributors)
- guru-trusted@gentoo.org (Reach the [trusted contributors](https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Trusted_Contributors))
- guru-devs@gentoo.org (Reach the Gentoo developers involved in GURU)
