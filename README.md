Redmine Wiki Graphviz-macro plugin
===

Redmine Wiki Graphviz-macro plugin make Redmine's wiki able to render graph image.

## Features

* Add wiki macro ```{{graphviz}}```, ```{{graphviz_link}}``` and ```{{graphviz_me}}```
* Write wiki page as dot format, and the macros make it graph image.

### {{graphviz}} macro

* This macro render graph image from other wiki page's content.

	```
    {{graphviz(Foo)}}
    {{graphviz(option=value,Foo)}}
    {{graphviz(layout=neato,target=_blank,with_source,Foo)}}
	```

* format={png|jpg|svg}
* layout={dot|neato|fdp|twopi|circo}
* inline={true|false}
	* If svg format is specified, Its default output is inline SVG. If inline is false, img tag will be used.
* target={_blank|any} (*1)
* with_source : Display both image and its source(dot) (*1)
* no_map : Disable clickable map. (*1)
* wiki=page : Link image to specified wiki page. (*1)
* link_to_image : Link image to itself. (*1)
* align=value : Additional attr for IMG. (*1)  
   e.g.) ```right```, ```left```
* width=value : Additional attr for IMG.   
	*  It is recommended to use no_map option together.  
       e.g.) ```100px```, ```200%```
* height=value : Additional attr for IMG. 
	* It is recommended to use no_map option together.  
      e.g.) ```100px```, ```200%```
* (*1): These options do not affect to the inline SVG.

### {{graphviz_me}} macro

* This macro render graph image from the wiki page which includes this macro. 
* Use this macro *commented out* like below. If it is not commented out, renderer fails syntax error.

	```
    // {{graphviz_me()}}
    // {{graphviz_me(option=value)}}
	```

* options: See ```{{graphviz}}``` macro.
* When previewing, this macro output the image into img@src with data scheme. Thus, old browsers can't render it.

### {{graphviz_link}} macro

* This macro render graph image having passing the dot description inline. 

	```
    {{graphviz_link()
    digraph G {...}
    }}
    {{graphviz_link(option=value)
    digraph G {...}
    }}
	```

* options: See ```{{graphviz}}``` macro.

## Tips

* Example

	```
    {{graphviz_link()
    digraph G {
      subgraph cluster_se {
        graph [label="Search Engine"]
        y [label="Yahoo!", URL="http://www.yahoo.com/"]
        g [label="Google", URL="http://www.google.com/"]
      }
      p [label="Page"]
      g -> p
    }
    }}
	```

## Requirement

* Redmine 4.0.0 or later.
* ruby 2.6
* Graphviz  http://www.graphviz.org
	* There are 2ways about setting up graphviz for this plugin.
	* The one is using Gv which is ruby binding of graphviz.
		* Recommended for unix system.
		* The plugin uses fork() and IO.pipe to capture STDERR which holds error message output from Gv.
	* The other one is using external dot command which is on the PATH.
		* For Windows system, Only this way of setting is available.
		* The dot command is executed twice by the plugin when one graph is rendered. First one to render the image. Second one to create clickable map.

  * Example of installed graphviz package.
    ```
    e.g.) CentOS 5.5 using Gv.
      graphviz-2.26.3-1.el5
      graphviz-gd-2.26.3-1.el5
      graphviz-ruby-2.26.3-1.el5
    e.g.) Ubuntu (10.04) using Gv.
      graphviz
      graphviz-dev
      libgv-ruby
    ```
* memcached (optional)

## Getting the plugin

https://github.com/tckz/redmine-wiki_graphviz_plugin

e.g.)
```
git clone https://github.com/tckz/redmine-wiki_graphviz_plugin.git wiki_graphviz_plugin
```


## Install

1. Copy the plugin tree into #{RAILS_ROOT}/plugins/

	```
    #{RAILS_ROOT}/plugins/
        wiki_graphviz_plugin/
	```
2. Make sure the temporary directory writable by the process of redmine.

	```
    #{RAILS_ROOT}/tmp/
	```

	This plugin try to create follwing directory and create tmporary file under it.

	```
    #{RAILS_ROOT}/tmp/wiki_graphviz_plugin/
	```

3. Restart Redmine.

### Optional

* If you want to use caching feature for rendered images, must configure your cache_store.
* This plugin expects the store like ```ActiveSupport::Cache::DalliStore``` which provides marshaling when set/get the value. 

<!-- dummy for breaking list -->

1. Setup caching environment, like memcached.
2. Install gem for caching.
   ```
   # e.g.) cd $RAILS_ROOT
   $ bundle add dalli
   ```
3. Configure cache_store.
   ```
   e.g.) config/environments/production.rb
   config.action_controller.perform_caching = true
   config.action_controller.cache_store = :dalli_cache_store, "localhost"
   ```
4. Restart Redmine.
5. Login to Redmine as an Administrator.
6. Setup wiki graphviz-macro settings in the Plugin settings panel.

## License

This plugin is licensed under the GNU GPL v2.  
See COPYRIGHT.txt and GPL.txt for details.

## Contribution

* graphviz_link macro by rsilvestri.

## My environment

* Based on docker image: redmine:5  
  https://hub.docker.com/_/redmine/
	* ruby-3.1.2p20
	* redmine-5.0.2
* graphviz-2.43.0
* dalli 3.2.2
