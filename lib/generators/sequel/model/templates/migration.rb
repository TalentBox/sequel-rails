Sequel.migration do 
  change do

    create_table :<%= table_name %> do
      primary_key :id
      <%- if options[:timestamps] -%>
      DateTime :created_at
      DateTime :updated_at
      <%- end -%>
      <%- attributes.each do |attribute| -%>
      <%= attribute.type_class %> :<%= attribute.name %>
      <%- end -%>
    end

  end
end