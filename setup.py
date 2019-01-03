# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools import find_packages

with open("VERSION") as f:
    version = f.read().strip()

description = ""

with open("README.md") as f:
    description += f.read() + "\n"

with open("HISTORY.txt") as f:
    description += f.read() + "\n"


setup(
    name="ynab_bank_import",
    version=version,
    author="Christian Theune",
    author_email="ct@gocept.com",
    description="YNAB bank import conversion scripts",
    long_description=description,
    license="BSD 2-clause",
    entry_points={
        "console_scripts": ["ynab_bank_import = ynab_bank_import.main:main"],
        "ynab_accounts": [
            "ing_checking = ynab_bank_import.ing_checking:do_import",
            "ing_aut_checking = ynab_bank_import.ing_aut_checking:do_import",
            "dkb_creditcard = ynab_bank_import.dkb_cc:do_import",
            "dkb_checking = ynab_bank_import.dkb_checking:do_import",
            "comdirect_checking = ynab_bank_import.comdirect:import_account",
            "comdirect_cc = ynab_bank_import.comdirect:import_cc",
            "mt940_csv = ynab_bank_import.mt940:import_account",
            "fiducia_csv = ynab_bank_import.fiducia:import_account",
            "sparkasse_cc = ynab_bank_import.sparkasse:import_cc",
        ],
    },
    keywords="import bank accounting personal finance",
    packages=find_packages("src"),
    package_dir={"": "src"},
    include_package_data=True,
)
