#
# This file is part of Edgehog.
#
# Copyright 2022-2024 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

defmodule Edgehog.BaseImages.BaseImageCollection do
  use Edgehog.MultitenantResource,
    domain: Edgehog.BaseImages,
    extensions: [
      AshGraphql.Resource
    ]

  alias Edgehog.Validations

  resource do
    description """
    Represents a collection of Base Images.

    A base image collection represents the collection of all Base Images that \
    can run on a specific System Model.
    """
  end

  graphql do
    type :base_image_collection

    queries do
      get :base_image_collection, :get
      list :base_image_collections, :list
    end

    mutations do
      create :create_base_image_collection, :create do
        relay_id_translations input: [system_model_id: :system_model]
      end

      update :update_base_image_collection, :update
      destroy :delete_base_image_collection, :destroy
    end
  end

  actions do
    create :create do
      description "Creates a new base image collection."
      primary? true

      accept [:handle, :name]

      argument :system_model_id, :id do
        description "The ID of the system model that is targeted by the base image collection"
        allow_nil? false
      end

      change manage_relationship(:system_model_id, :system_model, type: :append)
    end

    read :get do
      description "Returns a single base image."
      get? true
    end

    read :list do
      description "Returns a list of base images."
      primary? true
    end

    update :update do
      description "Updates a base image collection."
      primary? true
      require_atomic? false

      accept [:handle, :name]
    end

    destroy :destroy do
      description "Deletes a base image collection."
      primary? true
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      description "The display name of the base image collection."
      public? true
      allow_nil? false
    end

    attribute :handle, :string do
      description """
      The identifier of the base image collection.

      It should start with a lower case ASCII letter and only contain \
      lower case ASCII letters, digits and the hyphen - symbol.
      """

      public? true
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :system_model, Edgehog.Devices.SystemModel do
      description "The system model associated with the base image collection."
      public? true
      attribute_public? false
      allow_nil? false
    end
  end

  identities do
    # These have to be named this way to match the existing unique indexes
    # we already have. Ash uses identities to add a `unique_constraint` to the
    # Ecto changeset, so names have to match. There's no need to explicitly add
    # :tenant_id in the fields because identity in a multitenant resource are
    # automatically scoped to a specific :tenant_id
    # TODO: change index names when we generate migrations at the end of the porting
    identity :handle_tenant_id, [:handle]
    identity :name_tenant_id, [:name]
    identity :system_model_id_tenant_id, [:system_model_id]
  end

  validations do
    validate Validations.handle(:handle)
  end

  postgres do
    table "base_image_collections"
    repo Edgehog.Repo
  end
end
