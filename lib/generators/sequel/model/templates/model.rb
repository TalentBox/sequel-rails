class <%= class_name %><%= options[:parent] ? " < #{options[:parent].classify}" : " < Sequel::Model" %>
  <%- if options[:timestamps] -%>
  plugin :timestamps
  <%- end -%>
  
end
