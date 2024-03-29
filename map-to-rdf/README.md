# map-to-rdf

Historically, [Global Research Identifier Database
(GRID)](https://www.grid.ac/) was a database of research organisations
that was provided in various formats, including JSON and RDF.  It was
maintained by a commercial company, but the information was made
public.

The [Research Organization Registry (ROR)](https://ror.org/) was
created as a community-led project to maintain this information,
independent of any commercial company.  GRID has now "handed over" the
maintenance of their database to ROR.  There are no more releases of
the GRID database.

Currently, ROR provides their registry database in a [JSON
format](https://ror.readme.io/docs/ror-data-structure) only.  They do
not provide an RDF representation of that information, although there
there is an [open
issue](https://github.com/ror-community/ror-api/issues/113) to address
this.

This directory contains material that overcomes this limitation and
solves this issue.  It provides a way to convert the information from
ROR (in JSON) into a corresponding set of RDF triples.

## Information organisation

The information is expressed using a modified version of the [GRID
ontology](http://owlgred.lumii.lv/online_visualization/6thw).  This is
because, to a large extent, ROR inherited its database from GRID (not
too much has changed) and there may be existing users for whom this
ontology is already familiar.

GRID provided a description of their ontology using a standard
language: OWL.  This ontology is currently [available from GRID
directly](https://grid.ac/ontology/grid-ontology-v1.rdf).  This file
is serialised using the standard RDF/XML format.  While a perfectly
reasonable choice, other choices of serialisation may be easier for
people to read directly.  This repository contains the file
[`grid-ontology-v1.ttl`](https://github.com/paulmillar/ror-utils/blob/main/map-to-rdf/grid-ontology-v1.ttl),
which contains the same information but is serialised as Turtle.  You
may find this version easier to read.

Over time, ROR have modified their schema to include new ideas and
relationships.  To keep up, the original grid-ontology has been
updated.  This updated version is available as
`grid-ontology-v1.1.ttl`.

## How to map the JSON data.

The conversion (from JSON to RDF) of data from ROR uses [RDF Mapping
Language (RML)](https://rml.io/specs/rml/).  RML is a language for
describing how to convert a semi-structured file (such as JSON) into
RDF.  The RML language is intended to become a standard and is
reasonably well documented.

Different tools exist for doing the actual conversion; that is,
reading the mapping description (written in RML) and the input (ROR
JSON) and writing the corresponding RDF.  The conversion shown here is
done using the [RMLMapper
processor](https://github.com/RMLio/rmlmapper-java), an open-source
RML processor.


### Additional functions

A design philosophy of RML is that any value transformations
(converting a list of values to some related value) takes place
outside of RML, using externally defined functions.  For the ROR
data-dump, some of the input values must be transformed when
generating the corresponding RDF.  To do this, the mapping takes
advantage of some functions defined in the [RML Extra
Functions](https://github.com/paulmillar/rml-extra-functions)
repository.

Therefore, to use this mapping you must compile a `.jar` file from
this repository and place it in somewhere Java can access it (for
example, in the current-working directory) when running the RML
software.

The RML Extra Functions repository comes with a functions description
file: `functions.ttl`.  This file is needed so that RMLMapper can
identify which extra functions are available.  Therefore, the
`functions.ttl` file must be given to RMLMapper using the `-f`
command-line option; e.g., `-f functions.ttl`.

### Running the conversion

The following command shows how to convert the ROR data-dump file
`latest-ror-data.json` into a corresponding set of RDF triples. The
ROR JSON file may be obtained using the
[download-ror.sh](https://github.com/paulmillar/ror-utils/blob/main/bin/download-ror.sh)
script.

```console
$ java -jar rmlmapper-4.12.0-r360-all.jar -f functions.ttl -o output.ttl -s turtle -m mapping.ttl
$
```

Note that the location of the ROR JSON file is controlled from within
the `mapping.ttl` file.

The processing is relatively light-weight operation.  Converting a
full data-dump takes about 50 seconds on my laptop.

### Deviation from GRID RDF

The output is not identical to the RDF dump from GRID: there are a few
differences that are documented here.

The GRID RDF triples identify institutes by IRIs that are formed by
appending the GRID ID to `http://www.grid.ac/institutes/`.  The RDF
triples generated by this mapping (using the ROR data-dump) identify
institutes via their ROR identifier, which is already an IRI.

For example, the institute with GRID ID `grid.7683.a` is identified
under GRID RDFs using the IRI
`http://www.grid.ac/institutes/grid.7683.a`, while the same institute
has the ROR identifier `https://ror.org/01js2sh04`, which is used as
the IRI directly.

For both the GRID RDF and this RDF, the predicate
`http://www.grid.ac/ontology/id` (`grid:id`) indicates the GRID
identifier.  For example, here is a comparison of the assignment under
GRID:

```turtle
@prefix grid: <http://www.grid.ac/ontology/> .

<http://www.grid.ac/institutes/grid.7683.a> grid:id "grid.7683.a".
```

The following shows the same information under this mapping for ROR:

```turtle
@prefix grid: <http://www.grid.ac/ontology/> .

<https://ror.org/01js2sh04> grid:id "grid.7683.a".
```

Both GRID and RDF triples generated by this mapping identify the
address of an institute with an IRI formed by appending `/address-0`
on the intitute identifier; e.g.,
`http://www.grid.ac/institutes/grid.7683.a/address-0` and
`https://ror.org/01js2sh04/address-0`.  These are obviously different,
as the relative path (`address-0`) is resolved against different
institute IRIs.

### Example

Here is a complete example for a research organisation, showing
information about the institute and its address.

```turtle
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .
@prefix grid: <http://www.grid.ac/ontology/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
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
  grid:hasGeonamesCity <http://sws.geonames.org/2911298/>;
  geo:lat "53.575833"^^xsd:float;
  geo:long "9.879444"^^xsd:float .
```

The example comes from the mapping's output, by selecting only a
single institute (and its address), and by removing any `@prefix`
statements that are not used.

For comparison, here is the corresponding information from GRID:

```turtle
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix grid: <http://www.grid.ac/ontology/> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

<http://www.grid.ac/institutes/grid.7683.a>
        rdf:type               grid:Facility , foaf:Organization ;
        rdfs:label             "Deutsches Elektronen-Synchrotron DESY" ;
        grid:crossrefFunderId  "501100001647" ;
        grid:establishedYear   "1959"^^xsd:gYear ;
        grid:hasAddress        <http://www.grid.ac/institutes/grid.7683.a/address-0> ;
        grid:hasChild          <http://www.grid.ac/institutes/grid.494592.7> , <http://www.grid.ac/institutes/grid.466493.a> ;
        grid:hasParent         <http://www.grid.ac/institutes/grid.211011.2> ;
        grid:hasWikidataId     <http://www.wikidata.org/entity/Q39901428> , <http://www.wikidata.org/entity/Q311801> ;
        grid:id                "grid.7683.a" ;
        grid:isni              "0000 0004 0492 0453" ;
        grid:wikipediaPage     <http://en.wikipedia.org/wiki/DESY> ;
        skos:prefLabel         "Deutsches Elektronen-Synchrotron DESY" ;
        foaf:homepage          <http://www.desy.de/index_eng.html> .

<http://www.grid.ac/institutes/grid.7683.a/address-0>
        rdf:type              grid:Address ;
        grid:cityName         "Hamburg" ;
        grid:countryCode      "DE" ;
        grid:countryName      "Germany" ;
        grid:hasGeonamesCity  <http://sws.geonames.org/2911298/> ;
        <http://www.w3.org/2003/01/geo/wgs84_pos#lat>
                "53.575833"^^xsd:float ;
        <http://www.w3.org/2003/01/geo/wgs84_pos#long>
                "9.879444"^^xsd:float .
```