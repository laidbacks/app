require 'rails_helper'

RSpec.describe Api::V1::ProfilesController, type: :controller do
  let(:user) { User.create(username: 'testuser', password: 'password123', password_confirmation: 'password123') }

  describe 'GET #show' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get :show, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it 'returns the user profile data' do
        get :show, format: :json

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['username']).to eq('testuser')
        expect(json_response['id']).to eq(user.id)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        patch :update, params: { profile: { full_name: 'Test User' } }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it 'updates the user profile with valid data' do
        patch :update, params: { profile: { full_name: 'Test User', email: 'test@example.com' } }, format: :json

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['full_name']).to eq('Test User')
        expect(json_response['email']).to eq('test@example.com')
      end

      it 'returns errors with invalid data' do
        patch :update, params: { profile: { email: 'invalid-email' } }, format: :json

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end
  end
end
