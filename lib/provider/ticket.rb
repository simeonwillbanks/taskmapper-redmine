module TaskMapper::Provider
  module Redmine
    # Ticket class for taskmapper-yoursystem
    #
    API = RedmineAPI::Issue

    class Ticket < TaskMapper::Provider::Base::Ticket
      # declare needed overloaded methods here

      def initialize(*args)
        case args.first
          when Hash then super args.first
          when RedmineAPI::Issue then super args.first.to_ticket_hash
          else raise ArgumentError.new
        end
      end

      def created_at
        self[:created_on]
      end

      def updated_at
        self[:updated_on]
      end

      def project_id
        self[:project_id]
      end

      def status
        self[:status].name
      end

      def priority
        self[:priority].name
      end
      
      def requestor
        self[:author].name
      end

      def assignee
        self[:author].name
      end

      def id
        self[:id].to_i
      end
      
      def description
        self[:description]
      end

      def self.find_by_id(project_id, ticket_id)
       self.new API.find(:first, :id => ticket_id)
      end

      def self.find_by_attributes(project_id, attributes = {})
       issues = API.find(:all, attributes_for_request(project_id, attributes))
       issues.collect { |issue| self.new issue }
      end

      def self.attributes_for_request(project_id, options)
       hash = {:params => {:project_id => project_id}}.merge!(options)
      end

      def self.create(attributes)
        ticket = self.new(attributes)
        ticket if ticket.save
      end
      
      def save
        to_issue.new? ? to_issue.save : update
      end
      
      def comments
        warn "Redmine doesn't support comments"
        []
      end

      def comment
        warn "Redmine doesn't support comments"
        nil
      end

      def comment!
        warn "Redmine doesn't support comments"
        []
      end
      
      private
        def find_issue
          issue = API.find id, :params => {:project_id => self.project_id}
          raise TaskMapper::Exception.new "Ticket with #{id} was not found" unless issue
          issue
        end
        
        def update
          find_issue.update_with(self).save
        end
        
        def to_issue
          API.new.update_with(self)
        end

    end
  end
end
