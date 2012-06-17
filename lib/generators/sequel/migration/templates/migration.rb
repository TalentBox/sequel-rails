Sequel.migration do
  <%- if use_change -%>
  change do
    <%= table_action %>_table :<%= table_name %> do
      <%- if table_action == 'create' -%>
      primary_key :id
      <%- end -%>
      <%- attributes.each do |attribute| -%>
      <%- if table_action == 'create' -%>
      <%= attribute.type_class %> :<%= attribute.name %>
      <%- else -%>
      <%= column_action %>_column :<%= attribute.name %><% if column_action == 'add' %>, <%= attribute.type_class %><% end %>
      <%- end -%>
      <%- end -%>
    end
  end
  <%- else -%>
  up do
    <%- if table_action == 'drop' -%>
    drop_table :<%= table_name %>
    <%- else -%>
    <%= table_action %>_table :<%= table_name %> do
      <%- attributes.each do |attribute| -%>
      <%- if table_action == 'create' -%>
      <%= attribute.type_class %> :<%= attribute.name %>
      <%- else -%>
      <%= column_action %>_column :<%= attribute.name %><% if column_action == 'add' %>, <%= attribute.type_class %><% end %>
      <%- end -%>
      <%- end -%>
    end
    <%- end -%>
  end
  
  down do
    <%- alter_table_action = (table_action == 'drop') ? 'create' : table_action -%>
    <%- alter_column_action = (column_action == 'add') ? 'drop' : 'add' -%>
    <%= alter_table_action %>_table :<%= table_name %> do
      <%- attributes.each do |attribute| -%>
      <%- if alter_table_action == 'create' -%>
      <%= attribute.type_class %> :<%= attribute.name %>
      <%- else -%>
      <%= alter_column_action %>_column :<%= attribute.name %><% if alter_column_action == 'add' %>, <%= attribute.type_class %><% end %>
      <%- end -%>
      <%- end -%>
    end
  end
  <%- end -%>
end
