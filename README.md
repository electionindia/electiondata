Lok sabha 2014 election data
============

Lok Sabha 2014 election and constituency data scraped from:
http://affidavitarchive.nic.in/

To install dependencies run:

```sudo apt-get install ruby ruby-cmdparse```

To build/update data run:

```./election_data.rb --scrape```

To parse the information into a temporary json file

```./election_data.rb --parse```

To build usable json files

```./election_data.rb --buildjson```

Aims of this project:
============

* Collect and make available data related to candidates standing for elections in the Lok Sabha 2014 elections.
* Be apolitical. This is a data only project, and not an outlet for any particular political party.
* Complete transparency -- all information, and code related to the project are public.
* Neat and clean public interface of data -- so it's easy for anyone to find information about constituencies/candidates.

TODOs:
---
* ~~Write scraper~~
* ~~Write parser~~
* Build website to view information.

Thanks
---
* This project was inspired by the final episode of Satyamev Jayate season 2. Truth prevails more easily when information is available.
* Election commission of India website: http://affidavitarchive.nic.in/

