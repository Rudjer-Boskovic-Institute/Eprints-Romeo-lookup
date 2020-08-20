INSTALL INSTRUCTIONS

1. copy "Romeo.pm" to "$EPRINTS_ROOT/perl_lib/EPrints/Plugin/InputForm/Component/Romeo.pm"
  - we can probably use "$EPRINTS_ROOT/archives/$ARCHIVE_ID/plugin .. etc"
    - please contribute :)

2. edit Workflow in "$EPRINTS_ROOT/archives/$ARCHIVE_ID/cfg/workflows/eprint/default.xml" 

--- EXAMPLE PART

	<flow>
    		<stage ref="type"/>
    		<stage ref="core"/>
    		<epc:if test="type = 'article'">
        		<stage ref="policies"/>
    		</epc:if>
    		<stage ref="files"/>
    		<stage ref="subjects"/>
        </flow>

  	<stage name="policies">
    		<component type="Romeo" show_help="always">
    		</component>
  	</stage>

--- EXAMPLE END

  - we have changed Workflow a little bit because we want that users input ISSN first so in the next step we can check Romeo for that Journal
  - plugin is shown only for articles

3. restart Apache and test ..


Drop me an email in case you run into some troubles: alen@irb.hr  


*** Backup everything first, I cannot be responsible in case of failure ***
