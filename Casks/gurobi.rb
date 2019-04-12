cask 'gurobi' do
  version '8.1.1'
  sha256 'ef7459867ffa1f7455d3eca8ae6a621603c49b0369c3de882a730f198229d520'

  url "https://packages.gurobi.com/#{version.major_minor}/gurobi#{version}_mac64.pkg"
  appcast 'https://www.gurobi.com/resources/documentation/fixes'
  name 'Gurobi Optimizer'
  homepage 'https://www.gurobi.com/products/gurobi-optimizer'

  conflicts_with cask: 'gurobi80'

  pkg "gurobi#{version}_mac64.pkg"

  uninstall pkgutil: "com.gurobi.gurobiOptimizer#{version.no_dots}.gurobimac.pkg",
            delete:  [
                       "/Applications/Gurobi #{version}.app",
                       "/Library/gurobi#{version.no_dots}",
                       '/Library/Java/Extensions/gurobi.jar',
                       "/Library/Java/Extensions/libGurobiJni#{version.major_minor.no_dots}.jnilib",
                       '/usr/local/bin/gurobi_cl',
                       '/usr/local/bin/gurobi.env',
                       '/usr/local/bin/gurobi.sh',
                       '/usr/local/lib/gurobi.py',
                       "/usr/local/lib/libgurobi#{version.major_minor.no_dots}.dylib",
                       '/Library/Python/2.7/site-packages/gurobipy',
                       "/Library/Python/2.7/site-packages/gurobipy-#{version}-py2.7.egg-info",
                     ]

  caveats do
    files_in_usr_local
    license 'https://www.gurobi.com/pdfs/eula/eula-gurobi.pdf'
  end
end
