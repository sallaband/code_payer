class CreateBetaSignups < ActiveRecord::Migration
  def change
    create_table :beta_signups do |t|
      t.string :email

      t.timestamps null: false
    end
  end
end
