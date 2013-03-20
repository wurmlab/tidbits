#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
# 2010 summer- yannick wurm at insalien . org

$dataDir      = '../../data/' + File.basename(Dir.pwd) + '/'
###$srcDir    = '../../src/'

##includes##
['pathname','fileutils', 'logger', 'ywSequenceTools'].each do |lib| require lib; end
#other require 'find', 'rsruby', 'ruby-debug', 'test/unit'


##internal##
$log     = Logger.new(STDOUT)
$tempDir = 'tempDir'
###$r    = nil # for R statistics object

## functions ##

## tests ##

class TC_TestMethods < Test::Unit::TestCase
    # def setup      # end    # def teardown      # end
    #    def test_sameFastaIdentifiers()
    #        assert_equal(FALSE, sameFastaIdentifiers(fastaA.path, fastaC.path), "one empty")
    #        assert_raise(IOError) do  sameFastaIdentifiers(fastaA.path, 'nonexistantFile')
end
require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(TC_TestMethods)


## main ##
def main  
    raise IOError, 'Cannot find:'+ $dataDir if !File.exists?($dataDir)
    raise IOError, 'Not dir:    '+ $dataDir if !File.directory?($dataDir)
    $log.debug("Running with data from #{$dataDir}")


end


main
