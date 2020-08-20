=head1 NAME

EPrints::Plugin::InputForm::Component::Romeo

=cut

package EPrints::Plugin::InputForm::Component::Romeo;

use EPrints::Plugin::InputForm::Component;
@ISA = ( "EPrints::Plugin::InputForm::Component" );

use strict;
use JSON  qw( decode_json );
use LWP::Simple;
use Data::Dumper;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	
	$self->{name} = "Romeo";
	$self->{visible} = "all";
	# a list of documents to unroll when rendering, 
	# this is used by the POST processing, not GET

	return $self;
}

sub has_help
{
	my( $self, $surround ) = @_;
	return $self->{session}->get_lang->has_phrase( $self->html_phrase_id( "help" ) );
}

sub render_help
{
	my( $self, $surround ) = @_;
	return $self->html_phrase( "help" );
}

sub render_title
{
	my( $self, $surround ) = @_;
	return $self->html_phrase( "title" );
}

sub is_required
{
	my( $self ) = @_;
	return 0;
}

sub get_fields_handled
{
	my( $self ) = @_;

	return ( "documents" );
}

sub check_romeo 
{
	my( $self ) = @_;

	my $session = $self->{session};
	
	my $romeo = $session->make_doc_fragment;

	my $issn = $self->{dataobj}->get_value( "issn" );
	
	if( !defined $issn )
	{
	    $issn = 'romeo_issn_undefined';
	}

	my $div_ep_toolbox = $session->make_element( "div", class=>"ep_toolbox" );

	my $div_ep_toolbox_title = $session->make_element( "div", class=>"ep_toolbox_title" );
	$div_ep_toolbox_title->appendChild($self->html_phrase( "romeo" ));
	
	# Add html_phrase for undefined!
	$div_ep_toolbox_title->appendChild($session->make_text( $issn ));

	my $div_ep_toolbox_content = $session->make_element( "div", class=>"ep_toolbox_content" );
        $div_ep_toolbox_content->appendChild( $div_ep_toolbox_title );

        $div_ep_toolbox->appendChild( $div_ep_toolbox_content );
        $romeo->appendChild( $div_ep_toolbox );


	if( $issn eq 'romeo_issn_undefined.')
        {   
            return $romeo;
        }


		my $div_left = $session->make_element( "div", id=>"romeo_left" );
        	$div_ep_toolbox_content->appendChild( $div_left );

		my $div_right = $session->make_element( "div", id=>"romeo_right" );
        	$div_ep_toolbox_content->appendChild( $div_right );



	#my $url = URI->new("http://www.sherpa.ac.uk/romeo/api29.php");
        #$url->query_form( $url->query_form, issn => $issn, versions => 'all' , ak => '8pVXObMn3CU');
	# V2 Example
	#https://v2.sherpa.ac.uk/cgi/retrieve_by_id?item-type=publication&api-key=&format=Json&identifier=2056-5968

	my $RomeoURL = 'https://v2.sherpa.ac.uk/cgi/retrieve_by_id?item-type=publication&api-key=&format=Json&identifier=' . $issn;
	my $RomeoContent = get($RomeoURL)
   		or die "no such luck\n";

	my $dj = decode_json( $RomeoContent );

	#my $RomeoDump = Dumper $dj->{'items'}->[0]->{'publisher_policy'}->[0]->{'open_access_prohibited'};

# Set variables
	# Published in
	my $pub_title = $dj->{'items'}->[0]->{'title'}->[0]->{'title'};

	# Publisher
	my $pub_publisher = $dj->{'items'}->[0]->{'publishers'}->[0]->{'publisher'}->{'name'}->[0]->{'name'};

	# Publisher's default policy
	my $pub_policy_default = $dj->{'items'}->[0]->{'publisher_policy'}->[0]->{'open_access_prohibited'};

	# Publisher policy details 
	my $pub_policy_details = $dj->{'items'}->[0]->{'publisher_policy'}->[0]->{'uri'};


	# DIV Left Content START
	my $div_left_content = $session->make_element( "div" );		

		my $div_left_content_publishedIn_LABEL = $session->make_element( "h3" );
		$div_left_content_publishedIn_LABEL->appendChild($session->make_text("Published in:"));
		my $div_left_content_publishedIn_VALUE = $session->make_element( "p" );
		$div_left_content_publishedIn_VALUE->appendChild($session->make_text($pub_title));
		
	$div_left_content->appendChild($div_left_content_publishedIn_LABEL);
	$div_left_content->appendChild($div_left_content_publishedIn_VALUE);
		
		my $div_left_content_publisher_LABEL = $session->make_element( "h3" );
		$div_left_content_publisher_LABEL->appendChild($session->make_text("Publisher:"));
		my $div_left_content_publisher_VALUE = $session->make_element( "p" );
		$div_left_content_publisher_VALUE->appendChild($session->make_text($pub_publisher));
		
	$div_left_content->appendChild($div_left_content_publisher_LABEL);
	$div_left_content->appendChild($div_left_content_publisher_VALUE);

	# DIV Left Append Final
        $div_left->appendChild($div_left_content);
	
	# DIV Left Content END

	# DIV Right Content START
	my $div_right_content = $session->make_element( "div" );		

		my $div_right_content_policyDetails_LABEL = $session->make_element( "h3" );
		$div_right_content_policyDetails_LABEL->appendChild($session->make_text("Publisher's policy details:"));
		my $div_right_content_policyDetails_VALUE = $session->render_link($pub_policy_details, '_blank');
		$div_right_content_policyDetails_VALUE->appendChild($session->make_text($pub_policy_details));
		
	$div_right_content->appendChild($div_right_content_policyDetails_LABEL);
	$div_right_content->appendChild($div_right_content_policyDetails_VALUE);

	# DIV Right Append Final
        $div_right->appendChild($div_right_content);
	
	# DIV Right Content END

=pod

	my $xml = EPrints::XML::parse_url( $url );
        my $root = $xml->documentElement;

	foreach my $publisher ($xml->getElementsByTagName( "publisher" ) ) {

		my $div_left = $session->make_element( "div", id=>"romeo_left" );
        	$div_ep_toolbox_content->appendChild( $div_left );

		my $div_right = $session->make_element( "div", id=>"romeo_right" );
        	$div_ep_toolbox_content->appendChild( $div_right );
        	
		my $pubName = $publisher->getElementsByTagName( "name" )->item(0)->textContent;
            	my $pubAlias = $publisher->getElementsByTagName( "alias" )->item(0)->textContent;
            	my $pubURL = $publisher->getElementsByTagName( "homeurl" )->item(0)->textContent;
            	my $pubColor = $publisher->getElementsByTagName( "romeocolour" )->item(0)->textContent;
            	my $pubPreArchiving = $publisher->getElementsByTagName( "prearchiving" )->item(0)->textContent;
            	my $pubPostArchiving = $publisher->getElementsByTagName( "postarchiving" )->item(0)->textContent;

		my $div_left_pubname = $session->make_element( "h3", class=>"romeo_" . $pubColor );		

		$div_left_pubname->appendChild($session->make_text( $pubName." ".$pubAlias ));

		my $romeoUrl = $session->render_link( "http://www.sherpa.ac.uk/romeo/search.php?issn=".$issn, "_blank" );
		$romeoUrl->appendChild($session->make_text( "Publisher information @ RoMEo" ));

		my $pubUrl = $session->render_link( $pubURL, "_blank" );
		$pubUrl->appendChild($session->make_text( "Publisher website" ));

		my $div_left_romeo_url = $session->make_element( "p" );		
		$div_left_romeo_url->appendChild( $romeoUrl );
		
		my $div_left_pub_url = $session->make_element( "p" );		
		$div_left_pub_url->appendChild( $pubUrl );

		$div_left->appendChild( $div_left_pubname );
		$div_left->appendChild( $div_left_romeo_url );
		$div_left->appendChild( $div_left_pub_url );


		# RoMEo LEFT DIV START	

		$div_right->appendChild($session->make_text( "RoMEo color: " . $pubColor ));
		$div_right->appendChild($session->make_element( "br" ));

		if ($pubPreArchiving eq 'can') {
			$div_right->appendChild($session->make_element( "br" ));
			$div_right->appendChild($self->html_phrase( "romeo_preprint_can" ));
			$div_right->appendChild($session->make_element( "br" ));
		}
		if ($pubPreArchiving eq 'cannot') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_preprint_cannot" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
		if ($pubPreArchiving eq 'unclear' || $pubPreArchiving eq 'unknown') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_notice" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
		if ($pubPreArchiving eq 'restricted') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_preprint_restricted" ));

			my $pub_pre_restrictions = $session->make_element( "ul" );

                        foreach my $pubPreRestriction ( $publisher->getElementsByTagName( "prerestriction" ) ) {

                                my $pubPreRestrictionText = $session->make_element( "li" );
                                $pubPreRestrictionText->appendChild($session->make_text( $pubPreRestriction->textContent ));
                                $pub_pre_restrictions->appendChild($pubPreRestrictionText);

                        }

                        $div_right->appendChild($pub_pre_restrictions);

                }


		if ($pubPostArchiving eq 'can') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_postprint_can" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
                if ($pubPostArchiving eq 'cannot') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_postprint_cannot" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
                if ($pubPostArchiving eq 'unclear' || $pubPreArchiving eq 'unknown') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_notice" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
                if ($pubPostArchiving eq 'restricted') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_postprint_restricted" ));

			my $pub_post_restrictions = $session->make_element( "ul" );

                	foreach my $pubPostRestriction ( $publisher->getElementsByTagName( "postrestriction" ) ) {

                        	my $pubPostRestrictionText = $session->make_element( "li" );
                        	$pubPostRestrictionText->appendChild($session->make_text( $pubPostRestriction->textContent ));
                        	$pub_post_restrictions->appendChild($pubPostRestrictionText);

                	}

                	$div_right->appendChild($pub_post_restrictions);

                }


		my $div_right_pub_conditions_title = $session->make_element( "p", class=>"title" );
		$div_right_pub_conditions_title->appendChild($session->make_text( "Conditions" ));

		$div_right->appendChild($div_right_pub_conditions_title);

		my $div_right_pub_conditions = $session->make_element( "ul" );

		foreach my $pubCondition ( $publisher->getElementsByTagName( "condition" ) ) {
			
			my $div_right_pub_condition = $session->make_element( "li" );
			$div_right_pub_condition->appendChild($session->make_text( $pubCondition->textContent ));
			$div_right_pub_conditions->appendChild($div_right_pub_condition);

		}
		
		$div_right->appendChild($div_right_pub_conditions);


		my $div_right_pub_cplinks_title = $session->make_element( "p", class=>"title" );
                $div_right_pub_cplinks_title->appendChild($session->make_text( "Copyright links" ));

                $div_right->appendChild($div_right_pub_cplinks_title);

                my $div_right_pub_cplinks = $session->make_element( "ul" );

                foreach my $pubCplink ( $publisher->getElementsByTagName( "copyrightlink" ) ) {

                        my $div_right_pub_cplink = $session->make_element( "li" );

                        my $div_right_pub_cplink_a = $session->render_link ( $pubCplink->getElementsByTagName( "copyrightlinkurl" )->item(0)->textContent, "_blank" );
                	$div_right_pub_cplink_a->appendChild($session->make_text( $pubCplink->getElementsByTagName( "copyrightlinktext" )->item(0)->textContent ));
			$div_right_pub_cplink->appendChild($div_right_pub_cplink_a);

                        $div_right_pub_cplinks->appendChild($div_right_pub_cplink);

                }

                $div_right->appendChild($div_right_pub_cplinks);


		my $div_clear = $session->make_element( "div", style=>"clear: both" );
        	$div_ep_toolbox_content->appendChild( $div_clear );

	}
=cut
	my $div_clear = $session->make_element( "div", style=>"clear: both" );
       	$div_ep_toolbox_content->appendChild( $div_clear );

	return $romeo;
}


sub render_content
{
        my( $self, $surround ) = @_;

        my $session = $self->{session};
        my $f = $session->make_doc_fragment;

        my $html = $session->make_doc_fragment;
	$html->appendChild( $self->check_romeo );

        return $html;
}

1;
 
=head1 COPYRIGHT

=for COPYRIGHT BEGIN

SHERPA RoMEO check plugin for Eprints
(C) 2012 - Alen Vodopijevec <alen@irb.hr>

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

