# map-to-rdf

[Global Research Identifier Database (GRID)](https://www.grid.ac/)
maintained a database of research organisations and provided that
information in various formats, including JSON and RDF.

The [Research Organization Registry (ROR)](https://ror.org/) was
created as a community-led project to maintain this information,
independent of any commercial company.

Unfortunately, ROR (currently) provides the information only in a
[JSON format](https://ror.readme.io/docs/ror-data-structure).  They do
not provide an RDF representation of that information, although there
there is an [open issue](ror-community/ror-api#113) to address this.

This directory contains material to map the ROR-provided JSON data
into a corresponding set of RDF triples.

## Information organisation

The information is expressed using the [GRID
ontology](http://owlgred.lumii.lv/online_visualization/6thw).  This is
because, to a large extent, ROR inherited its database from GRID and
there may be existing users for whom this ontology is already
familiar.

The file `grid-ontology-v1.ttl` contains a description of the GRID
ontology, serialised using the turtle format.  This is hopefully
easier to read than [the RDF/XML
serialisation](https://grid.ac/ontology/grid-ontology-v1.rdf) that
GRID provides.

### Deviation from GRID RDF

The RDF triples use the ROR identifiers as the predicate's subject,
not the GRID identifier.  The GRID identifiers are asserted using the
`grid:id` predicate, just as GRID did.  This may provide sufficient
interoperability for existing users.

## How to map the JSON data.

The conversion from JSON to RDF uses [RDF Mapping Language
(RML)](https://rml.io/specs/rml/) to describe how the different parts
of the JSON data should be understood.  RML is intended to become a
standard and is reasonably well documented.

### Additional functions

The RML philosphy is that value transformations are enacted outside of
RML, by using functions.  Some of the input values must be
transformed.  To do this, the mapping makes use of the functions
defined in the [RML Extra
Functions](https://github.com/paulmillar/rml-extra-functions)
repository.  Therefore, the jar file from that project must be built
and the corresponding functions description (`functions.ttl`) needs to
be on the RMLMapper command line.

### Problems and work-arounds

The ROR data-dump contains many entries with a `wikipedia_url` entry
that contains the empty string (`""`).  This does not work well with
RML and such values must first be converted to `null` values.

One way to achieve this work-around with the data-dump
`2021-09-23-ror-data.json` is the following command:

```console
paul@sprocket:~/ROR$ sed -ie 's/"wikipedia_url": "",/"wikipedia_url": null,/' 2021-09-23-ror-data.json
```

This command updates the file `2021-09-23-ror-data.json` and creates a
backup of the original contents as `2021-09-23-ror-data.jsone`.

### Running the conversion

The following command illustrates how to convert a ROR data-dump
`2021-09-23-ror-data.json` into a corresponding set of RDF triples.
The conversion shown here is done using the [RMLMapper
processor](https://github.com/RMLio/rmlmapper-java), an open-source
RML processor.

```console
paul@sprocket:~/ROR$ java -jar rmlmapper-4.12.0-r360-all.jar -f functions.ttl -o output.ttl -s turtle -m mapping.ttl
paul@sprocket:~/ROR$
```

Just for comparison, it takes about 40 seconds to process a full
data-dump on my laptop.

Here is an example entry from the resulting output:

```turtle
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix grid: <http://www.grid.ac/ontology/> .
@prefix ql: <http://semweb.mmlab.be/ns/ql#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rml: <http://semweb.mmlab.be/ns/rml#> .
@prefix rr: <http://www.w3.org/ns/r2rml#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix vivo: <http://vivoweb.org/ontology/core#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<https://ror.org/01js2sh04> a grid:Facility, foaf:Organization;
  grid:crossrefFunderId "501100001647";
  grid:establishedYear "1959"^^xsd:gYear;
  grid:hasAddress "https://ror.org/01js2sh04/address-0";
  grid:hasChild <https://ror.org/02zmk8084>, <https://ror.org/04fme8709>;
  grid:hasParent <https://ror.org/0281dp749>;
  grid:hasWikidataId <http://www.wikidata.org/entity/Q311801>, <http://www.wikidata.org/entity/Q39901428>;
  grid:id "grid.7683.a";
  grid:isni "0000 0004 0492 0453";
  grid:wikipediaPage <http://en.wikipedia.org/wiki/DESY>;
  rdfs:label "Deutsches Elektronen-Synchrotron DESY";
  skos:prefLabel "Deutsches Elektronen-Synchrotron DESY";
  foaf:homepage <http://www.desy.de/index_eng.html> .

<https://ror.org/01js2sh04/address-0> a grid:Address;
  grid:cityName "Hamburg";
  grid:countryCode "DE";
  grid:countryName "Germany";
  grid:hasGeonamesCity <http://sws.geonames.org/2911298/> .
```
