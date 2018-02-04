# SEEK

This is a fork of [SEEK](https://github.com/seek4science/seek) altered to be used with the Management System for Models and Simulations [MaSyMoS](https://github.com/ronhenkel/masymos-core) 

## About the original SEEK

The SEEK platform is a web-based resource for sharing heterogeneous scientific research datasets,models or simulations, processes and research outcomes. It preserves associations between them, along with information about the people and organisations involved.
Underpinning SEEK is the ISA infrastructure, a standard format for describing how individual experiments are aggregated into wider studies and investigations. Within SEEK, ISA has been extended and is configurable to allow the structure to be used outside of Biology.

SEEK is incorporating semantic technology allowing sophisticated queries over the data, yet without getting in the way of your users.

For an example of SEEK please visit our [Demo](http://demo.seek4science.org/).

To see SEEK being used for real science, as part of [FAIRDOM](http://fair-dom.org) please visit [FAIRDOM SEEK](http://fairdomhub.org)

For more information please visit: [SEEK for Science](http://www.seek4science.org/)

## Installation

Please follow the installation guideline provided at https://github.com/seek4science/seek for this fork. Make sure the external search services are availabel. Once SEEK is running, follow the set up instructions for the server mode of [masymos-core](https://github.com/ronhenkel/masymos-core) and [masymos-morre](https://github.com/ronhenkel/masymos-morre). 

If SEEK and the Neo4J server running MaSyMoS are not on the same machine, configure masymos_url in seek_configuration.rb-openseek to point to the Neo4J installation. Make sure that SEEK and the Neo4J server are accessible!

## Add and search models
Add models to your SEEK instance if the model is SBML encoded, MaSyMoS will be notified and index the model. Once models are added, use SEEK's external search to retrieve your models. An additional panel 'MaSyMoS' will provide the external search results.

## Disclaimer
This is a proof of concept and not necessarily fail safe.
