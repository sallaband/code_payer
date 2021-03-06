require 'csv_generator' 
class ReportsController < ApplicationController
  # before_action :set_report, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
    render text: "ok"
  end

  def new
  end

  def download_file
    if params[:download][:period].present?
      if params[:download][:period]=="date_interval"
          start_date = report_params[:start_date] + " 00:00:00"
          end_date = report_params[:end_date] + " 11:59:59"
      elsif params[:download][:period]=="single_date"
            start_date = report_params[:single_date] + " 00:00:00"
            end_date = report_params[:single_date] + " 11:59:59"
      end
    else
      particular_date = report_params[:particluar_date]  
    end  

    type = report_params[:type]
    respond_to do |format|
    format.csv do
        case type 

        when "bills"
            @bills = current_user.created_bills.where(:created_at => start_date..end_date)    
            if @bills.present?
              csv_g = CsvGenerator.new(@bills)
              send_data(csv_g.bill_to_csv, :filename => "bills.csv")
            else
              flash[:error] = "There is no bill for selected dates" 
              redirect_to :back
            end
        
        when "bills_aging" 
            @bills = current_user.created_bills.where(created_at: start_date..end_date, paid: false)
            if @bills.present?
              csv_g = CsvGenerator.new(@bills)
              send_data(csv_g.unpaid_bills_to_csv, :filename => "bills_a/p_aging.csv")
            else
              flash[:error] = "There is no unpaid bills for selected dates" 
              redirect_to :back
            end
        
        when "vendor_balance"
          @bills = current_organization.bills.where("due_date <= ? AND paid = ?", particular_date, false)
          @vendor_ids = @bills.map(&:vendor_id).uniq
          if @bills.present?        
            csv_g = CsvGenerator.new(@bills) 
            send_data(csv_g.vendors_bills_to_csv, :filename => "vendors_balance.csv")
          else
            flash[:error] = "There is no unpaid bill having due date under selected date" 
            redirect_to :back
          end

        when "payment"         
             @payments = current_organization.bill_informations.where(processing_date: start_date..end_date)
            if @payments.present?
              csv_g = CsvGenerator.new(@payments)
              send_data(csv_g.payments_to_csv, :filename => "payments.csv")
            else
              flash[:error] = "There is no payment processed on seleted date" 
              redirect_to :back
            end

        # when "invoices"
        #     @invoices = current_user.created_invoices.where(:created_at => start_date..end_date)
        #     if @invoices.present?
        #       csv_g = CsvGenerator.new(@invoices)
        #       send_data(csv_g.invoice_to_csv, :filename => "invoices.csv")
        #     else
        #       flash[:error] = "There is no invoice for selected dates" 
        #       redirect_to :back
        #     end
                    
        # when "unpaid_invoices" 
        #     @invoices = current_user.created_invoices.where(created_at: start_date..end_date, received: false)
        #     if @invoices.present?
        #       csv_g = CsvGenerator.new(@invoices)
        #       send_data(csv_g.unpaid_invoice_to_csv, :filename => "unpaid_invoices.csv")
        #     else
        #       flash[:error] = "There is no unpaid invoice for selected dates" 
        #       redirect_to :back
        #     end
             
        else
          flash[:error] = "Wrong option seleted"
          redirect_to :back
        end
      end

      format.pdf do 
        case type
        
        when "bills"
          @bills = current_organization.bills.where(:created_at => start_date..end_date)
          if @bills.present?         
            render pdf: "bills", layout: 'pdf.html.erb', disposition: :send_file
          else
            flash[:error] = "There is no bill for selected dates" 
            redirect_to :back
          end

        when "bills_aging"
          bills = current_organization.bills.where(:created_at => start_date..end_date, paid: false)
          @due_not_passed_bills = bills.where("due_date > ?", Date.today)
          @due_passed_30_days_bills = bills.where("due_date <= ? and due_date > ?", Date.today, (Date.today-30.days))
          @due_30_to_60_days_bills = bills.where("due_date <= ? and due_date > ?", (Date.today-30.days), (Date.today-60.days))
          @due_60_to_90_days_bills = bills.where("due_date <= ? and due_date > ?", (Date.today-60.days), (Date.today-90.days))
          @due_above_90_bills = bills.where("due_date <= ?", (Date.today-90.days))
          if bills.present?         
            render pdf: "bills_a/p_aging", layout: 'pdf.html.erb', disposition: :send_file
          else
            flash[:error] = "There is no unpaid bills for selected dates" 
            redirect_to :back
          end

        when "vendor_balance"
          @bills = current_organization.bills.where("due_date <= ? AND paid = ?", particular_date, false)
          @vendor_ids = @bills.map(&:vendor_id).uniq
          if @bills.present?         
            render pdf: "vendors_balance", layout: 'pdf.html.erb', disposition: :send_file
          else
            flash[:error] = "There is no unpaid bills for having due date under selected date" 
            redirect_to :back
          end

        when "payment"
          @payments = current_organization.bill_informations.where(processing_date: start_date..end_date)
          if @payments.present?         
            render pdf: "payments", layout: 'pdf.html.erb', disposition: :send_file
          else
            flash[:error] = "There is no payment for seleted processed date" 
            redirect_to :back
          end

        # when "invoices"
        #   @invoices = current_user.created_invoices.where(:created_at => start_date..end_date)
        #   if @invoices.present?         
        #     render pdf: "download_file", layout: 'pdf.html.erb'
        #   else
        #     flash[:error] = "There is no invoice for selected dates" 
        #     redirect_to :back
        #   end
  
        # when "unpaid_invoices"
        #   invoices = current_user.created_invoices.where(:created_at => start_date..end_date, received: false)
        #   @due_not_passed_invoices = invoices.where("due_date > ?", Date.today)
        #   @due_passed_30_days_invoices = invoices.where("due_date <= ? and due_date > ?", Date.today, (Date.today-30.days))
        #   @due_30_to_60_days_invoices = invoices.where("due_date <= ? and due_date > ?", (Date.today-30.days), (Date.today-60.days))
        #   @due_60_to_90_days_invoices = invoices.where("due_date <= ? and due_date > ?", (Date.today-60.days), (Date.today-90.days))
        #   @due_above_90_invoices = invoices.where("due_date <= ?", (Date.today-90.days))
        #   if invoices.present?         
        #     render pdf: "download_file", layout: 'pdf.html.erb'
        #   else
        #     flash[:error] = "There is no unpaid invoice for selected dates" 
        #     redirect_to :back
        #   end

        else  
          flash[:error] = "Wrong option seleted"
          redirect_to :back
        end
      end  
    end  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      if params[:download][:period].present?  
        if params[:download][:period]=="date_interval"
            params.require(:download).permit(:type, 
                      :start_date, 
                      :end_date 
                      )
        elsif params[:download][:period]=="single_date"
            params.require(:download).permit(:type, 
                      :single_date  
                      )
        end
      else
        params.require(:download).permit(:type, 
                      :particluar_date  
                      )  
      end      
    end

end
