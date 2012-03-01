class UsersController < ApplicationController
  
   def show
     @user = User.find(params[:id])
   end
  
   def new
     @user = User.new
   end

   def create
     @user = User.new(params[:user])
     if @user.save
       redirect_to root_url, :notice => "Signed up!"
     else
       render "new"
     end
   end
   
   
   def edit
     @user = User.find(params[:id])
   end
     
   def update
     @user = User.find(params[:id])

     respond_to do |format|
       if @user.update_attributes(params[:user])
         format.html { redirect_to @user, notice: 'Deck was successfully updated.' }
         format.json { head :ok }
       else
         format.html { render action: "edit" }
         format.json { render json: @user.errors, status: :unprocessable_entity }
       end
     end
   end
end
