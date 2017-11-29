import urllib2
from bs4 import BeautifulSoup
import re
import sys
import time
import datetime
import json

class BiocPackage:
    """Bioconductor Package"""
    def __init__(self, name, downloads_total, downloads_month, description, tags, authors, license, page):
        self.name = name
        self.downloads_total = downloads_total
        self.downloads_month = downloads_month
        self.description = description
        self.tags = tags
        self.authors = authors
        self.license = license
        self.page = page

    def parse(self):
        return {
                'name': self.name,
                'downloads_total': self.downloads_total,
                'downloads_month': self.downloads_month,
                'description': self.description,
                'tags': self.tags,
                'authors': self.authors,
                'license': self.license,
                'page': self.page
                }


        
class PackageList:
    """List of Bioconductor Packages"""
    def __init__(self):
        self.pkg_list = []

    def add_package(self, package):
        self.pkg_list.append(package)

    def sort_packages(self):
        self.pkg_list = sorted(self.pkg_list, key=lambda pkg: pkg.downloads_total)

    def top(self, n):
        return sorted(self.pkg_list, key=lambda pkg: pkg.downloads_total)[:n]


def get_packages():
    url = 'http://bioconductor.org/packages/stats/index.html'
    response = urllib2.urlopen(url)
    html = response.read()
    soup = BeautifulSoup(html)

    packages = soup.find_all('tr', {'class': 'pkg_index'})

    pkg_list = PackageList()

    for package in packages:
        if package.find('a').string != None:
            pkg_name = re.search('(.*)\(', package.find('a').string).group(1).strip()
            print 'Processing %s' % pkg_name
            dl_all = re.search('\((\d+)\)', package.find('a').string).group(1)
            link = 'http://bioconductor.org/packages/stats/' + package.find('a').get('href')
        
            response = urllib2.urlopen(link)
            html = response.read()
            soup = BeautifulSoup(html)
            page = soup.find_all('a')[1].get('href')
            now = datetime.datetime.now()
            prev_month = ((now.month - 2) % 12) + 1;
            dl_month = soup.find('table', {'class': 'stats'}).find_all('tr')[prev_month].find_all('td')[1].string

            if re.search('\.html$', page) and not re.search('/release/extra', page):
            
                response = urllib2.urlopen(page)
                html = response.read()
                soup = BeautifulSoup(html)
            
                description = get_description(soup)
                authors = get_authors(soup)
                tags = get_tags(soup)
                license = get_license(soup)

                pkg_list.add_package(BiocPackage(pkg_name, dl_all, dl_month, description, tags, authors, license, page))

    return pkg_list


def get_description(soup):
    description = soup.find('div', {'class': 'do_not_rebase'}).find_all('p')[1].string
    return description


def get_authors(soup):
    authors = soup.find('div', {'class': 'do_not_rebase'}).find_all('p')[2].string.strip('Author: ')
    return authors


def get_tags(soup):
    tag_elements = soup.find('table', {'class': 'details'}).find_all('tr')[0].find_all('td')[1].find_all('a')
    tags = [x.string for x in tag_elements]
    return tags


def get_license(soup):
    license = soup.find('table', {'class': 'details'}).find_all('tr')[3].find_all('td')[1].string
    return license


def write_data(packages):
    with open('bioC.json', 'w') as f:
        f.write('var data = ' + packages + ';')


def main():
    packages = get_packages()  

    write_data(json.dumps([p.parse() for p in packages.pkg_list]))

if __name__ == '__main__':
    main()