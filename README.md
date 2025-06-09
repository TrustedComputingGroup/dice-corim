# corim
CDDL definition of CoRIM as defined by TCG DICE Working Group

To generate a release and export dice-corim.cddl file do the following:
```sh
reltag=cddl-$(git rev-parse --short HEAD)
git tag -a $reltag
git push origin $reltag
```
After CI completes go to dice-corim landing page and inspect `Releases` under the `About` heading.

