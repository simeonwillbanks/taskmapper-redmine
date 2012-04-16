module TicketMaster::Provider
  module Redmine
    # Ticket class for ticketmaster-yoursystem
    #
    API = RedmineAPI::Issue

    class Ticket < TicketMaster::Provider::Base::Ticket
      # declare needed overloaded methods here

      def initialize(*args)
        case args.first
          when Hash then super args.first
          when RedmineAPI::Issue then super args.first.to_ticket_hash
          else raise ArgumentError.new
        end
      end
      
      def self.copy(issue_hash, ticket_hash)
      end

      def created_at
        self[:created_on]
      end

      def updated_at
        self[:updated_on]
      end

      def project_id
        self[:project].id.to_i
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

      def self.find(project_id, *options)
       if options.first.is_a? Hash
         options[0].merge!(:params => {:project_id => project_id})
         super(*options)
       elsif options.empty?
         issues =  RedmineAPI::Issue.find(:all, :params => {:project_id => project_id}).collect { |issue| TicketMaster::Provider::Redmine::Ticket.new issue }
       elsif options[0].first.is_a? Fixnum
         self.find_by_id(project_id, options[0].first)
       else
         super(*options)
       end
      end

      def self.find_by_id(project_id, ticket_id)
       self.new API.find(:first, :id => ticket_id)
      end

      def self.find_by_attributes(project_id, attributes = {})
       issues = API.find(:all, build_attributes(project_id, attributes))
       issues.collect { |issue| self.new issue }
      end

      def self.build_attributes(repo, options)
       hash = {:repo => repo}.merge!(options)
      end

      def self.create(attributes)
        ticket = self.new(attributes)
        ticket if ticket.save
      end
      
      def save
        return update if id && !id.zero?
        self.to_issue.save
      end
      
      def to_issue
        API.new.tap do |i|
          i.subject = title,
          i.description = description,
          i.project_id = project_id
        end
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
      
    end
  end
end

#This is for debugging propouse
class Net::HTTP
  def send(*args)
    p "<<< Net::HTTP#send(#{args.inspect}) >>>"
    resp = super
    p "<<< Response = #{resp.inspect} >>>"
    resp
  end
end
