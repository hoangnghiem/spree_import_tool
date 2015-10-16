Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "utilities_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :partial => "spree/admin/utilities/menu",
                     :disabled => false)