# clone git repository sparsely with just one subdirectory only
cd ~/dev/programs/python
git init pims_temp
cd pims_temp
git remote add -f origin https://github.com/baluneboy/biomedken.git
git config core.sparseCheckout true
echo "pims/sandbox" >> .git/info/sparse-checkout
echo "pims/ugaudio" >> .git/info/sparse-checkout
git pull origin master